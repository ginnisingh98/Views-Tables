--------------------------------------------------------
--  DDL for Package Body AR_BILLS_MAINTAIN_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_MAINTAIN_LIB_PVT" AS
/* $Header: ARBRMALB.pls 120.14.12010000.2 2009/08/21 06:18:48 mpsingh ship $ */


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
C_ENDORSED				CONSTANT VARCHAR2(30)	:=	'ENDORSED';


/* =======================================================================
 | Bills Receivable event constants
 * ======================================================================*/

C_MATURITY_DATE				CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE';
C_RISK_ELIMINATED			CONSTANT VARCHAR2(30)	:=	'RISK_ELIMINATED';
C_COMPLETED				CONSTANT VARCHAR2(30)	:=	'COMPLETED';

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


/* =======================================================================
 | Bills Receivable remittance method code constants
 * ======================================================================*/

C_STANDARD				CONSTANT VARCHAR2(30)	:=	'STANDARD';
C_FACTORING				CONSTANT VARCHAR2(30)	:=	'FACTORING';


/* =======================================================================
 | Parameter p_called_from for the Receipt API
 * ======================================================================*/

C_BR_REMITTED				CONSTANT VARCHAR2(30)	:=	'BR_REMITTED';
C_BR_FACTORED_RECOURSE			CONSTANT VARCHAR2(30)	:=	'BR_FACTORED_WITH_RECOURSE';
C_BR_FACTORED				CONSTANT VARCHAR2(30)	:=	'BR_FACTORED_WITHOUT_RECOURSE';



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Get_Doc_Seq				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Document Sequence Routine							|
 |										|
 +==============================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Get_Doc_Seq (	p_appid			IN	NUMBER	,
			p_trx_rec		IN OUT NOCOPY	RA_CUSTOMER_TRX%ROWTYPE,
			p_sob_id		IN	NUMBER	,
			p_met_code		IN	VARCHAR2) IS

l_cat_code		VARCHAR2(20)	;
l_doc_seq_ret_stat   	NUMBER		;
l_doc_sequence_name  	VARCHAR2(50)	;
l_doc_sequence_type  	VARCHAR2(50)	;
l_doc_sequence_value 	NUMBER		;
l_db_sequence_name  	VARCHAR2(50)	;
l_seq_ass_id  		NUMBER		;
l_prd_tab_name  	VARCHAR2(50)	;
l_aud_tab_name  	VARCHAR2(50)	;
l_msg_flag      	VARCHAR2(1)	;
pg_profile_doc_seq	VARCHAR2(1)	;
l_copy_doc_number_flag	VARCHAR2(1)	;
l_count			NUMBER		;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Get_Doc_Seq ()+');
	END IF;


	SELECT	count(*)
	INTO	l_count
	FROM	AR_TRANSACTION_HISTORY
	WHERE	customer_trx_id	=	p_trx_rec.customer_trx_id
	AND	event		=	C_COMPLETED;


	IF	(l_count	= 0)
	THEN

		--	The BR has never been completed

		pg_profile_doc_seq	:=	fnd_profile.value('UNIQUE:SEQ_NUMBERS');

	        IF PG_DEBUG in ('Y', 'C') THEN
	           arp_util.debug( 'SEQ : '||NVL( pg_profile_doc_seq, 'N'));
	        END IF;

		SELECT 	name
		INTO	l_cat_code
		FROM	ra_cust_trx_types
		WHERE	cust_trx_type_id = p_trx_rec.cust_trx_type_id;

		IF   ( NVL( pg_profile_doc_seq, 'N') <> 'N' )
	        THEN
	           BEGIN
        		IF PG_DEBUG in ('Y', 'C') THEN
        		   arp_util.debug( 'Seq numbering on');
        		END IF;

	                /*------------------------------+
	                |  Get the document sequence.   |
	                +------------------------------*/

		        l_doc_seq_ret_stat:=
        	              fnd_seqnum.get_seq_info (
			                 app_id  	=>  p_appid			,
  		                         cat_code 	=>  l_cat_code			,
                                         sob_id		=>  p_sob_id			,
                                         met_code	=>  p_met_code			,
                                         trx_date	=>  trunc(p_trx_rec.trx_date)	,
                                         docseq_id	=>  p_trx_rec.doc_sequence_id	,
                                         docseq_type	=>  l_doc_sequence_type		,
                                         docseq_name	=>  l_doc_sequence_name		,
                                         db_seq_name	=>  l_db_sequence_name		,
                                         seq_ass_id	=>  l_seq_ass_id		,
                                         prd_tab_name	=>  l_prd_tab_name		,
                                         aud_tab_name	=>  l_aud_tab_name		,
                                         msg_flag	=>  l_msg_flag			,
                                         suppress_error	=>  'N'				,
                                         suppress_warn	=>  'Y'				);

			--arp_util.debug('Doc sequence return status : '||to_char(nvl(l_doc_seq_ret_stat,-99)));
        	     	--arp_util.debug('l_doc_sequence_name        : '||l_doc_sequence_name);
	             	--arp_util.debug('l_doc_sequence_id          : '||to_char(nvl(l_doc_sequence_id,-99)));


	               	IF  	(l_doc_seq_ret_stat = -8) THEN

        	           	-- Sequential Numbering is always used and there is
                	      	-- no assignment for this set of parameters

	                   	IF PG_DEBUG in ('Y', 'C') THEN
	                   	   arp_util.debug( '>>>>>>>>>> The doc sequence does not exist for the current document');
	                   	END IF;

              	               	FND_MESSAGE.Set_Name( 'AR','AR_BR_DOC_SEQ_NOT_EXIST_A');
                	 	app_exception.raise_exception;

        	       	ELSIF 	(l_doc_seq_ret_stat = -2)  THEN

				-- No assignment exists for the set of parameters
				-- this is the case of Partially Used

	                	IF PG_DEBUG in ('Y', 'C') THEN
	                	   arp_util.debug( '>>>>>>>>>> Warning : The doc sequence does not exist for the current document');
	                	END IF;

	          	END IF;

/* Bug 3632787 Needed to trim l_doc_sequence_type as I found that it was passing some null in the value */

                        l_doc_sequence_type := ltrim(rtrim(l_doc_sequence_type));

/* Bug 3632787 Added condition to check l_doc_sequence_type for all the three conditions */


			IF ( l_doc_sequence_name IS NOT NULL) AND (p_trx_rec.doc_sequence_id IS NOT NULL)
                           AND (l_doc_sequence_type <> 'M')
        	        THEN
                		/*------------------------------------+
                        	|  Automatic Document Numbering case  |
	                        +------------------------------------*/

	                	IF PG_DEBUG in ('Y', 'C') THEN
	                	   arp_util.debug( 'Automatic Document Numbering case ');
	                	END IF;

	                        l_doc_seq_ret_stat := fnd_seqnum.get_seq_val (
		                            	p_appid			,
		                                l_cat_code		,
		                                p_sob_id		,
                                                p_met_code		,
                                                trunc(p_trx_rec.trx_date),
                                                l_doc_sequence_value	,
                                                p_trx_rec.doc_sequence_id);

	                      	IF  (p_trx_rec.doc_sequence_value IS NOT NULL) THEN
        	              		--raise an error message because the user is not supposed to pass
                	      		--in a value for the document sequence number in this case.
                        	 	IF PG_DEBUG in ('Y', 'C') THEN
                        	 	   arp_util.debug( '>>>>>>>>>> The user is not supposed to pass in a value in this case');
                        	 	END IF;
                         		FND_MESSAGE.Set_Name('AR', 'AR_BR_DOC_SEQ_AUTOMATIC');
					app_exception.raise_exception;
                	      	END IF;

				p_trx_rec.doc_sequence_value := l_doc_sequence_value;
	                        arp_util.debug('l_doc_sequence_value :'||to_char(nvl(p_trx_rec.doc_sequence_value,-99)));



			ELSIF (p_trx_rec.doc_sequence_id IS NOT NULL) AND (p_trx_rec.doc_sequence_value IS NOT NULL)
                              AND (l_doc_sequence_type = 'M')
        	        THEN
	                     	/*-------------------------------------+
        	                |  Manual Document Numbering case      |
                	        |  with the document value specified.  |
	                        |  Use the specified value.            |
        	                +-------------------------------------*/

	                        NULL;


	               	ELSIF (p_trx_rec.doc_sequence_id IS NOT NULL) AND (p_trx_rec.doc_sequence_value IS NULL)
                              AND (l_doc_sequence_type = 'M')
        	        THEN
                	        /*-----------------------------------------+
	                        |  Manual Document Numbering case         |
        	                |  with the document value not specified. |
                	        |  Generate a document value mandatory    |
                        	|  error.                                 |
	                        +-----------------------------------------*/

	                        IF (NVL(pg_profile_doc_seq,'N') = 'A')
				THEN
        	                        IF PG_DEBUG in ('Y', 'C') THEN
        	                           arp_util.debug( '>>>>>>>>>> A - pg_profile_doc_seq : ' || pg_profile_doc_seq);
        	                        END IF;
					FND_MESSAGE.Set_Name('AR', 'AR_BR_DOC_SEQ_VALUE_NULL_A');
					FND_MESSAGE.Set_Token('SEQUENCE', l_doc_sequence_name);
	                                app_exception.raise_exception;

	                        ELSIF (NVL(pg_profile_doc_seq,'N') = 'P')
				THEN
                	             	--Warning
					IF PG_DEBUG in ('Y', 'C') THEN
					   arp_util.debug( '>>>>>>>>>> P - pg_profile_doc_seq : ' || pg_profile_doc_seq);
					END IF;
                             		FND_MESSAGE.SET_NAME('AR','AR_BR_DOC_SEQ_VALUE_NULL_P');
					app_exception.raise_exception;

                	        END IF;


	               	END IF;

		        EXCEPTION
        	           WHEN NO_DATA_FOUND THEN
                	     	/*------------------------------------------+
	                        |  No document assignment was found.       |
	                        |  Generate an error if document numbering |
	                        |  is mandatory.                           |
	                        +------------------------------------------*/
        	                IF PG_DEBUG in ('Y', 'C') THEN
        	                   arp_util.debug( 'no_data_found raised');
        	                END IF;

				IF   (pg_profile_doc_seq = 'A' ) THEN
	                            	IF PG_DEBUG in ('Y', 'C') THEN
	                            	   arp_util.debug( '>>>>>>>>>> no_data_found raised - pg_profile_doc_seq = A');
	                            	END IF;
		                        FND_MESSAGE.Set_Name( 'FND','UNIQUE-ALWAYS USED');
                		        app_exception.raise_exception;
	                        ELSE
				    IF PG_DEBUG in ('Y', 'C') THEN
				       arp_util.debug( '>>>>>>>>>> no_data_found raised - pg_profile_doc_seq : ' || pg_profile_doc_seq);
				    END IF;
                	            p_trx_rec.doc_sequence_id    := NULL;
                        	    p_trx_rec.doc_sequence_value := NULL;
	                        END IF;

	                   WHEN OTHERS THEN
        	             	IF PG_DEBUG in ('Y', 'C') THEN
        	             	   arp_util.debug( '>>>>>>>>>> Unhandled exception in doc sequence assignment');
        	             	END IF;
                	     	raise;

	             	END;

		END IF;


		/*======================================================================+
	 	|  Copy Document Number to transaction number if "copy document to 	|
	 	|  transaction number" flag is checked in batch sources			|
 		+=======================================================================*/

		BEGIN

		SELECT 	copy_doc_number_flag
		INTO	l_copy_doc_number_flag
		FROM	RA_BATCH_SOURCES
		WHERE	batch_source_id	  =    p_trx_rec.batch_source_id;

		EXCEPTION
		   WHEN NO_DATA_FOUND THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug( '>>>>>>>>>> Bacth Source does not exist');
			END IF;
			FND_MESSAGE.Set_Name( 'AR','AR_BR_INVALID_BATCH_SOURCE');
			app_exception.raise_exception;
		   WHEN OTHERS THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug( '>>>>>>>>>> Failed when fetching copy doc number flag');
			END IF;
		END;

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Copy Doc Number Flag : ' || l_copy_doc_number_flag);
		END IF;

		IF  (NVL(l_copy_doc_number_flag,'N') = 'Y') 	AND
		    (p_trx_rec.doc_sequence_value IS NOT NULL)	AND
		    (p_trx_rec.old_trx_number     IS NULL    )
		THEN
		    p_trx_rec.old_trx_number	:=	p_trx_rec.trx_number;
		    p_trx_rec.trx_number	:=	p_trx_rec.doc_sequence_value;
		END IF;

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Old Trx Number : ' || p_trx_rec.trx_number);
		   arp_util.debug( 'New Trx Number : ' || p_trx_rec.trx_number);
		END IF;

	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Get_Doc_Seq ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Get_Doc_Seq () ');
		   arp_util.debug( 'p_appid    = ' || p_appid);
		   arp_util.debug( 'p_sob_id   = ' || p_sob_id);
		   arp_util.debug( 'p_met_code = ' || p_met_code);
		END IF;
		RAISE;

END Get_Doc_Seq;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Set_API_Error					                        |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Put the error message generated by the adjustment API or the receipt API	|
 |    on the message stack.							|
 |										|
 +==============================================================================*/

PROCEDURE Set_API_Error
IS

l_data		       	varchar2(4000);
l_msg_index_out        	number;

BEGIN
	arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Set_API_Error ()+');

	FND_MSG_PUB.Get (FND_MSG_PUB.G_FIRST, FND_API.G_TRUE, l_data, l_msg_index_out);
	FND_MESSAGE.Set_Encoded (l_data);
	app_exception.raise_exception;
	arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Set_API_Error ()-');

EXCEPTION
	WHEN OTHERS THEN
		arp_util.debug('>>>>>>>>>> EXCEPTION : Set_API_Error () ');
		RAISE;

END Set_API_Error;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Get_Remittance_Batch				                        |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    For a given BR, find the remittance batch information (if it exists)	|
 |										|
 +==============================================================================*/

PROCEDURE Get_Remittance_Batch ( p_customer_trx_id	IN 	NUMBER	,
				 p_batch_rec		OUT NOCOPY 	ar_batches%ROWTYPE)
IS

  -- Added for bug # 2712726
  -- ORASHID
  --
  l_nocopy_batch_id  ar_batches.batch_id%TYPE;

BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Get_Remittance_Batch ()+');
	END IF;


	--  Get the remittance batch id in ra_customer_trx_id

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ( 'Customer_Trx_Id  	:  ' ||  p_customer_trx_id);
	END IF;

	SELECT 	remittance_batch_id
	INTO	p_batch_rec.batch_id
	FROM 	ra_customer_trx
	WHERE 	customer_trx_id = p_customer_trx_id;

        -- Modified for bug # 2712726
        -- ORASHID
        --
        l_nocopy_batch_id := p_batch_rec.batch_id;
	arp_cr_batches_pkg.fetch_p(l_nocopy_batch_id, p_batch_rec);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ( 'Remittance Batch ID : ' || p_batch_rec.batch_id);
	   arp_util.debug ( 'Remittance Method   : ' || p_batch_rec.remit_method_code);
	   arp_util.debug ( 'With Recourse Flag  : ' || p_batch_rec.with_recourse_flag);
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Get_Remittance_Batch ()-');
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The BR has not been remitted yet');
		END IF;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Get_Remittance_Batch () ');
		   arp_util.debug( 'p_customer_trx_id = ' || p_customer_trx_id);
		END IF;
		RAISE;

END Get_Remittance_Batch;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Update_Reserved_Columns			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Update the reserved type and reserved value of the payment schedule	|
 |										|
 +==============================================================================*/

PROCEDURE Update_Reserved_Columns  ( p_payment_schedule_id	IN 	NUMBER	,
			   	     p_reserved_type       	IN 	VARCHAR2,
				     p_reserved_value		IN	NUMBER	)
IS

l_ps_rec	ar_payment_schedules%ROWTYPE;

BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Update_Reserved_Columns ()+ ');
	END IF;

	arp_ps_pkg.lock_p(p_payment_schedule_id);

	arp_ps_pkg.set_to_dummy (l_ps_rec);

	l_ps_rec.payment_schedule_id	:=	p_payment_schedule_id;
	l_ps_rec.reserved_type 		:=	p_reserved_type;
	l_ps_rec.reserved_value		:=	p_reserved_value;

	arp_ps_pkg.update_p (l_ps_rec, l_ps_rec.payment_schedule_id);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Update_Reserved_Columns ()- ');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Update_Reserved_Columns () ');
		   arp_util.debug( 'p_payment_schedule_id    = ' || p_payment_schedule_id);
		   arp_util.debug( 'p_reserved_type          = ' || p_reserved_type);
		   arp_util.debug( 'p_reserved_value         = ' || p_reserved_value);
		END IF;
		RAISE;

END Update_Reserved_Columns;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Action_Dates			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults the action date and action gl date 				|
 |    Ex : Acceptance Date and Acceptance GL date				|
 |										|
 +==============================================================================*/


PROCEDURE Default_Action_Dates 	( p_trx_date	IN OUT NOCOPY	AR_TRANSACTION_HISTORY.trx_date%TYPE,
			     	  p_gl_date	IN OUT NOCOPY	AR_TRANSACTION_HISTORY.gl_date%TYPE )

IS

l_return_status	VARCHAR2(1);

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates()+ ');
   	END IF;

	----  Default the action date if NULL
  	IF (p_trx_date IS NULL) THEN
		Select 	SYSDATE
    		into 	p_trx_date
    		from 	dual;
  	END IF;


	----  Default the action GL Date if NULL

	IF (p_gl_date IS NULL)
	THEN
		AR_BILLS_CREATION_LIB_PVT.Default_gl_date(
				sysdate		,
                		p_gl_date	,
                    		l_return_status	);
	ELSE
		AR_BILLS_CREATION_VAL_PVT.Validate_GL_Date (p_gl_date);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug( 'Default_gl_date Return_status : '||l_return_status);
  	   arp_util.debug( 'GL Date defaulted : ' || p_gl_date);
 	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates()-');
 	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Default_Action_Dates () ');
		   arp_util.debug( 'p_trx_date    = ' || p_trx_date);
		   arp_util.debug( 'p_gl_date     = ' || p_gl_date);
		END IF;
		RAISE;

END Default_Action_Dates;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Complete_Or_Accept			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Depending on the action :							|
 |	  - BR Completion, No Acceptance Required				|
 |	  - BR Acceptance							|
 |										|
 +==============================================================================*/



PROCEDURE Complete_Or_Accept (p_trh_rec  IN OUT NOCOPY	ar_transaction_history%ROWTYPE)
IS

l_adj_acctd_amount	NUMBER;

CURSOR 	assignment_cur IS
	SELECT 	br_ref_customer_trx_id, br_ref_payment_schedule_id, extended_amount,
                customer_trx_line_id, extended_acctd_amount
	FROM	ra_customer_trx_lines
	WHERE	customer_trx_id = p_trh_rec.customer_trx_id;

assignment_rec	assignment_cur%ROWTYPE	;

l_trh_rec	AR_TRANSACTION_HISTORY%ROWTYPE	;
l_ps_rec	AR_PAYMENT_SCHEDULES%ROWTYPE	;
l_trx_rec	RA_CUSTOMER_TRX%ROWTYPE		;
l_new_adjust_id	NUMBER				;
l_move_deferred_tax	VARCHAR2(1)	:=  'N'	;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Complete_Or_Accept ()+');
	END IF;

	/*----------------------------------------------+
        |  For each assignment, create a non accounting |
	|  Adjustment with status A			|
        +-----------------------------------------------*/

	FOR  assignment_rec  IN  assignment_cur LOOP

		arp_ps_pkg.fetch_p (assignment_rec.br_ref_payment_schedule_id, l_ps_rec);

		IF	(l_ps_rec.tax_remaining IS NOT NULL	and	l_ps_rec.tax_remaining <> 0)
		THEN
			l_move_deferred_tax	:=	'Y';
		END IF;

		Create_Adjustment   ( 	p_trh_rec					,
					assignment_rec.br_ref_customer_trx_id		,
					l_ps_rec					,
					assignment_rec.extended_amount			,
					-15						,
					'A'						,
					l_move_deferred_tax				,
					l_new_adjust_id					);


		/*----------------------------------------------+
        	|   Update the Assignment Information with 	|
		|   the Adjustment ID				|
        	+-----------------------------------------------*/

		arp_ctl_pkg.lock_p (assignment_rec.customer_trx_line_id);

		UPDATE	ra_customer_trx_lines
		SET	br_adjustment_id   	=	l_new_adjust_id
		WHERE	customer_trx_line_id 	=	assignment_rec.customer_trx_line_id;


		/*----------------------------------------------+
        	|  Update the reserved columns of the exchanged |
		|  Payment Schedule				|
        	+-----------------------------------------------*/

		update_reserved_columns (assignment_rec.br_ref_payment_schedule_id, NULL, NULL);


		/*----------------------------------------------+
        	|  If the transaction to be exchanged is a BR,	|
		|  create a CLOSED history record		|
        	+-----------------------------------------------*/


		IF 	(AR_BILLS_CREATION_VAL_PVT.Is_Transaction_BR (l_ps_rec.cust_trx_type_id))
		THEN

			ARP_CT_PKG.fetch_p (l_trx_rec, assignment_rec.br_ref_customer_trx_id);
			l_trh_rec.customer_trx_id	:=	assignment_rec.br_ref_customer_trx_id;
			ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

			-- Fetch the new status and new event of the BR

			AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
				p_trx_rec	=>	l_trx_rec		,
				p_action        =>	C_EXCHANGE_COMPLETE	,
				p_new_status	=>	l_trh_rec.status	,
				p_new_event	=>	l_trh_rec.event		);

			l_trh_rec.transaction_history_id:=	NULL		;
			l_trh_rec.current_record_flag	:=  	'Y'		;
			l_trh_rec.prv_trx_history_id	:=  	NULL		;
			l_trh_rec.posting_control_id    := 	-3           	;
			l_trh_rec.gl_posted_date        :=  	NULL        	;
			l_trh_rec.first_posted_record_flag  := 	'N'		;
			l_trh_rec.created_from		:=	'ARBRMAIB'	;
			l_trh_rec.postable_flag		:=	'N'		;
			l_trh_rec.current_accounted_flag:=  	'N'		;

			arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
										 l_trh_rec.transaction_history_id);
		END IF;

	END LOOP;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Complete_Or_Accept ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Complete_Or_Accept () ');
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		RAISE;

END Complete_Or_Accept;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Complete_Acc_Required			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    BR Pending Acceptance is Completed					|
 |										|
 +==============================================================================*/


PROCEDURE Complete_Acc_Required (p_customer_trx_id  IN 	ra_customer_trx.customer_trx_id%TYPE)
IS


CURSOR 	assignment_cur IS
	SELECT 	br_ref_payment_schedule_id
	FROM	ra_customer_trx_lines
	WHERE	customer_trx_id = p_customer_trx_id;

assignment_rec	assignment_cur%ROWTYPE	;


l_ps_rec	AR_PAYMENT_SCHEDULES%ROWTYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Complete_Acc_Required ()+');
	END IF;

	/*----------------------------------------------+
        |  For each assignment, update the reserved	|
	|  columns of the PS				|
        +-----------------------------------------------*/

	FOR  assignment_rec  IN  assignment_cur LOOP
		update_reserved_columns (assignment_rec.br_ref_payment_schedule_id, 'TRANSACTION', p_customer_trx_id);
	END LOOP;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Complete_Acc_Required ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Complete_Acc_Required: ' || '>>>>>>>>>> EXCEPTION : Complete_Or_Accept () ');
		   arp_util.debug('Complete_Acc_Required: ' || 'p_customer_trx_id : ' || p_customer_trx_id);
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		RAISE;

END Complete_Acc_Required;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Create_Adjustment		         		               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 | 	Calls the Adjustment API to create an adjustment			|
 |										|
 +==============================================================================*/


PROCEDURE Create_Adjustment   ( p_trh_rec		IN  	ar_transaction_history%ROWTYPE			,
				p_customer_trx_id	IN	ra_customer_trx.customer_trx_id%TYPE		,
				p_ps_rec		IN	ar_payment_schedules%ROWTYPE			,
				p_amount		IN	NUMBER						,
				p_receivables_trx_id	IN  	ar_receivables_trx.receivables_trx_id%TYPE	,
				p_status		IN  	VARCHAR2					,
				p_move_deferred_tax	IN	VARCHAR2					,
				p_adj_id		OUT NOCOPY 	ar_adjustments.adjustment_id%TYPE		)
IS

adj_rec                	ar_adjustments%rowtype;
l_msg_count            	number :=0;
l_msg_data             	varchar2(2000);
l_return_status        	varchar2(1);
new_adj_num            	ar_adjustments.adjustment_number%type;
l_app_short_name	varchar2(30);
l_message_name		varchar2(30);
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Create_Adjustment ()+');
	END IF;

       /* SSA change */
       l_org_id := p_trh_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Create_adjustment : l_org_return_status <> SUCCESS');
       ELSE

	adj_rec.type			:=  'INVOICE'				;
	adj_rec.payment_schedule_id	:=  p_ps_rec.payment_schedule_id	;
	adj_rec.amount			:=  -(p_amount)				;
	adj_rec.customer_trx_id		:=  p_customer_trx_id			;
	adj_rec.receivables_trx_id	:=  p_receivables_trx_id		;
	adj_rec.created_from		:=  'ARBRMAIB'				;
	adj_rec.apply_date		:=  p_trh_rec.trx_date			;
	adj_rec.gl_date			:=  p_trh_rec.gl_date			;
	adj_rec.reason_code		:=  ''					;
	adj_rec.comments		:=  p_trh_rec.comments			;
	adj_rec.status			:=  p_status				;
        adj_rec.org_id                  :=  p_trh_rec.org_id                    ;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  '-----------------------------------------');
	   arp_util.debug ('PARAMETERS PASSED TO AR_ADJUST_PUB.Create_Adjustment :');
	   arp_util.debug (  'adj_rec.payment_schedule_id : ' || adj_rec.payment_schedule_id);
	   arp_util.debug (  'adj_rec.amount              : ' || adj_rec.amount);
	   arp_util.debug (  'adj_rec.customer_trx_id     : ' || adj_rec.customer_trx_id);
	   arp_util.debug (  'adj_rec.receivables_trx_id  : ' || adj_rec.receivables_trx_id);
	   arp_util.debug (  'adj_rec.apply_date          : ' || adj_rec.apply_date);
	   arp_util.debug (  'adj_rec.gl_date             : ' || adj_rec.gl_date);
	   arp_util.debug (  'adj_rec.comments            : ' || adj_rec.comments);
	   arp_util.debug (  'adj_rec.status              : ' || adj_rec.status);
           arp_util.debug (  'adj_rec.org_id              : ' || adj_rec.org_id);
	   arp_util.debug (  'p_move_deferred_tax         : ' || p_move_deferred_tax);
	   arp_util.debug (  '-----------------------------------------');
	END IF;

	AR_ADJUST_PUB.Create_Adjustment (
		p_api_name	=>	'AR_ADJUST_PUB'		,
		p_api_version	=>	1.0			,
		p_init_msg_list	=>	FND_API.G_TRUE		,
		p_msg_count	=>	l_msg_count		,
		p_msg_data	=>	l_msg_data		,
		p_return_status =>	l_return_status		,
		p_adj_rec	=>	adj_rec			,
		p_chk_approval_limits	=>  'F'			,
		p_check_amount		=>  'F'			,
		p_move_deferred_tax   	=>  p_move_deferred_tax	,
		p_new_adjust_number 	=>  new_adj_num		,
		p_new_adjust_id		=>  p_adj_id		,
                p_org_id                =>  adj_rec.org_id);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'return status  : ' || l_return_status);
	   arp_util.debug (  'msg_count	: ' || l_msg_count);
	   arp_util.debug (  'msg_data	: ' || l_msg_data);
	END IF;


	IF  (l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Adjustment Creation');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;

		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_CREATE_ADJ');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'Adjustment ID created : ' ||  p_adj_id);
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Create_Adjustment ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Create_Adjustment () ');
		   arp_util.debug(  'p_customer_trx_id    : ' || p_customer_trx_id);
		   arp_util.debug(  'p_receivables_trx_id : ' || p_receivables_trx_id);
		   arp_util.debug(  'p_status	     : ' || p_status);
		   arp_util.debug(  'p_amount	     : ' || p_amount);
		   arp_util.debug(  'p_move_deferred_tax  : ' || p_move_deferred_tax);
		END IF;
		RAISE;

END Create_Adjustment;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Find_Last_Adjustment			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Find the last endorsement adjustment on the BR				|
 |										|
 +==============================================================================*/


PROCEDURE Find_Last_Adjustment (p_customer_trx_id  IN 	ra_customer_trx.customer_trx_id%TYPE	,
				p_adj_id	   OUT NOCOPY	ar_adjustments.adjustment_id%TYPE	)

IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Adjustment ()+');
	END IF;

	SELECT	max(adjustment_id)
	INTO	p_adj_id
	FROM	ar_adjustments
	WHERE	customer_trx_id		=	p_customer_trx_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Adjustment ()-');
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Find_Last_Adjustment: ' || 'No Endorsement Adjustment was found for the BR');
		END IF;
		RAISE;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Adjustment () ');
		   arp_util.debug('Find_Last_Adjustment: ' || 'p_customer_trx_id : ' || p_customer_trx_id);
		END IF;
		RAISE;

END Find_Last_Adjustment;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Approve_Adjustment		         		               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 | 	Calls the Adjustment API to approve an adjustment			|
 |										|
 +==============================================================================*/


PROCEDURE Approve_Adjustment  (	p_adj_id	  	IN	ar_adjustments.adjustment_id%TYPE,
			    	p_move_deferred_tax	IN	VARCHAR2			 )
IS


l_msg_data      VARCHAR2(2000)		;
l_msg_count	NUMBER			;
l_return_status	VARCHAR2(1)		;
l_adj_rec	AR_ADJUSTMENTS%ROWTYPE	;

l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Approve_Adjustment ()+');
        END IF;

       /* SSA change */
       select org_id
         into l_org_id
         from ar_adjustments
        where adjustment_id = p_adj_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Approve_Adjustment : l_org_return_status <> SUCCESS');
       ELSE


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '--------------------------------------------------------------');
	   arp_util.debug('PARAMETERS PASSED TO AR_ADJUST_PUB.Approve_Adjustment : ');
	   arp_util.debug(  'p_old_adjust_id         	: ' || p_adj_id);
	   arp_util.debug(  'p_chk_approval_limits	: ' || 'F');
	   arp_util.debug(  'p_move_deferred_tax        : ' || p_move_deferred_tax);
	   arp_util.debug(  'p_adj_rec.status           : ' || l_adj_rec.status);
           arp_util.debug(  'p_org_id                   : ' || l_org_id);
	   arp_util.debug(  '--------------------------------------------------------------');
	END IF;


	AR_ADJUST_PUB.Approve_Adjustment (
				p_api_name		=>	'AR_ADJUST_PUB'		,
				p_api_version		=>	1.0			,
				p_init_msg_list		=>	FND_API.G_TRUE		,
				p_msg_count		=>	l_msg_count		,
				p_msg_data		=>	l_msg_data		,
				p_return_status 	=>	l_return_status		,
				p_adj_rec		=>	l_adj_rec		,
				p_chk_approval_limits	=>	FND_API.G_FALSE		,
				p_move_deferred_tax	=>	p_move_deferred_tax	,
				p_old_adjust_id	      	=>  	p_adj_id		,
                                p_org_id                =>      l_org_id);

	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Adjustment Approval');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_APPROVE_ADJ');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Approve_Adjustment ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Approve_Adjustment : ' || SQLERRM);
		   arp_util.debug(  'p_adj_id : ' || p_adj_id);
		END IF;
		RAISE;

END Approve_Adjustment;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Modify_Adjustment		         		               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 | 	Calls the Adjustment API to modify the status of the adjustment		|
 |										|
 +==============================================================================*/


PROCEDURE Modify_Adjustment  (	p_adj_id  	IN 	AR_ADJUSTMENTS.adjustment_id%TYPE,
				p_status	IN	AR_ADJUSTMENTS.status%TYPE	 )
IS


l_msg_data      VARCHAR2(2000)		;
l_msg_count	NUMBER			;
l_return_status	VARCHAR2(1)		;
l_adj_rec	ar_adjustments%ROWTYPE	;
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Modify_Adjustment ()+');
	END IF;

       /* SSA change */
       select org_id
         into l_org_id
         from ar_adjustments
        where adjustment_id = p_adj_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Modify_Adjustment : l_org_return_status <> SUCCESS');
       ELSE

	l_adj_rec.status  := p_status;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '--------------------------------------------------------------');
	   arp_util.debug('PARAMETERS PASSED TO AR_ADJUST_PUB.Modify_Adjustment : ');
	   arp_util.debug(  'p_old_adjust_id         	: ' || p_adj_id);
	   arp_util.debug(  'p_chk_approval_limits	: ' || 'F');
	   arp_util.debug(  'p_adj_rec.status           : ' || l_adj_rec.status);
           arp_util.debug(  'p_org_id                   : ' || l_org_id);
	   arp_util.debug(  '--------------------------------------------------------------');
	END IF;


     	AR_ADJUST_PUB.Modify_Adjustment(
        	p_api_name             =>   'AR_ADJUST_PUB'	,
	        p_api_version          =>   1.0			,
		p_init_msg_list	       =>   FND_API.G_TRUE	,
	        p_msg_count            =>   l_msg_count		,
	        p_msg_data             =>   l_msg_data		,
	        p_return_status        =>   l_return_status	,
	        p_adj_rec              =>   l_adj_rec		,
        	p_chk_approval_limits  =>   'F'			,
	        p_old_adjust_id        =>   p_adj_id	        ,
                p_org_id               =>   l_org_id 	);


	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Adjustment Modification');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_MODIFY_ADJ');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Modify_Adjustment ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Modify_Adjustment : ' || SQLERRM);
		   arp_util.debug(  'p_adj_id : ' || p_adj_id);
		   arp_util.debug(  'p_status : ' || p_status);
		END IF;
		RAISE;

END Modify_Adjustment;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Reverse_Adjustment		         		               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 | 	Calls the Adjustment API to reverse an adjustment			|
 |										|
 +==============================================================================*/


PROCEDURE Reverse_Adjustment  ( p_adj_id	  IN	ar_adjustments.adjustment_id%TYPE	,
				p_trh_rec	  IN	ar_transaction_history%ROWTYPE		,
				p_called_from	  IN	VARCHAR2				)
IS


l_msg_data      VARCHAR2(2000)		;
l_msg_count	NUMBER			;
l_return_status	VARCHAR2(1)		;
l_new_adjust_id	NUMBER			;

l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

 l_customer_trx	  ra_customer_trx%ROWTYPE;


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Adjustment ()+');
        END IF;

       /* SSA change */
       l_org_id := p_trh_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Adjustment : l_org_return_status <> SUCCESS');
       ELSE

        IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '--------------------------------------------------------------');
	   arp_util.debug('PARAMETERS PASSED TO AR_ADJUST_PUB.Reverse_Adjustment : ');
	   arp_util.debug(  'p_old_adjust_id         	     : ' || p_adj_id);
	   arp_util.debug(  'p_reversal_date                 : ' || p_trh_rec.trx_date);
	   arp_util.debug(  'p_reversal_gl_date              : ' || p_trh_rec.gl_date);
	   arp_util.debug(  'p_comments                      : ' || p_trh_rec.comments);
	   arp_util.debug(  'p_chk_approval_limits	     : ' || 'F');
	   arp_util.debug(  'p_move_deferred_tax             : ' || 'Y');
	   arp_util.debug(  'p_called_from	   	     : ' || p_called_from);
           arp_util.debug(  'p_org_id                        : ' || p_trh_rec.org_id);
	   arp_util.debug(  '--------------------------------------------------------------');
	END IF;

	AR_ADJUST_PUB.Reverse_Adjustment (
				p_api_name		=>	'AR_ADJUST_PUB'		,
				p_api_version		=>	1.0			,
				p_init_msg_list		=>	FND_API.G_TRUE		,
				p_msg_count		=>	l_msg_count		,
				p_msg_data		=>	l_msg_data		,
				p_return_status 	=>	l_return_status		,
				p_old_adjust_id		=>	p_adj_id		,
				p_reversal_date		=>	p_trh_rec.trx_date	,
				p_reversal_gl_date	=>	p_trh_rec.gl_date	,
				p_comments		=>	p_trh_rec.comments	,
				p_chk_approval_limits	=>	'F'			,
				p_move_deferred_tax	=>	'Y'			,
				p_new_adj_id	      	=>  	l_new_adjust_id         ,
				p_called_from		=>	p_called_from		,
                                p_org_id                =>      p_trh_rec.org_id);

	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Adjustment Reversal');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_REVERSE_ADJ');
			app_exception.raise_exception;
		END IF;
        ELSE -- Bug 8795268 Line Level for invoice is not maintained correctly.
	     begin

	       select adj.customer_trx_id,ra.upgrade_method
	       into l_customer_trx.customer_trx_id, l_customer_trx.upgrade_method
	       from ar_adjustments adj,ra_customer_trx ra
	       where adj.adjustment_id = l_new_adjust_id
	       and ra.customer_trx_id = adj.customer_trx_id;

	     exception
	       when others then
		  arp_util.debug(  '>>>>>>>>>> Problems during balance stamping select query');
		  arp_util.debug (  'Adjustment ID : ' ||  l_new_adjust_id);
	     end;

	     IF l_customer_trx.upgrade_method = 'R12' THEN
		 ARP_DET_DIST_PKG.set_original_rem_amt_r12(
		  p_customer_trx => l_customer_trx,
		  x_return_status   =>  l_return_status,
		  x_msg_count       =>  l_msg_count,
		  x_msg_data        =>  l_msg_data,
		  p_from_llca       => 'N');

		  IF	(l_return_status <> 'S')
		  THEN
		    IF PG_DEBUG in ('Y', 'C') THEN
		       arp_util.debug(  '>>>>>>>>>> Problems balance stamping');
		       arp_util.debug(  'l_return_status : ' || l_return_status);
		       arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		       arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		    END IF;
		  END IF;
	     END IF;

	END IF;
	END IF;



	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'Adjustment ID : ' ||  l_new_adjust_id);
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Adjustment ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Adjustment : ' || SQLERRM);
		   arp_util.debug(  'p_adj_id : ' || p_adj_id);
		END IF;
		RAISE;

END Reverse_Adjustment;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Reverse_Assignments_Adjustment		                        	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Reverse the adjustments created when standard transactions are exchanged|
 |	Remove the adjustment ID in the assignment information			|
 |	Update the reserved columns of the PS of the exchanged transactions	|
 |										|
 |	Called by UNCOMPLETE_BR and CANCEL_BR					|
 |										|
 +==============================================================================*/


PROCEDURE Reverse_Assignments_Adjustment    ( 	p_trh_rec	   IN	AR_TRANSACTION_HISTORY%ROWTYPE	,
						p_acceptance_flag  IN	VARCHAR2			)
IS

CURSOR 	assignment_cur IS
	SELECT 	br_adjustment_id, br_ref_payment_schedule_id, customer_trx_line_id, br_ref_customer_trx_id
	FROM	ra_customer_trx_lines
	WHERE	customer_trx_id = p_trh_rec.customer_trx_id;

assignment_rec	assignment_cur%ROWTYPE	;

l_msg_data      VARCHAR2(2000)		;
l_msg		VARCHAR2(240)		;
l_msg_count	NUMBER			;
l_return_status	VARCHAR2(1)		;
l_ps_rec	ar_payment_schedules%ROWTYPE	;
l_trx_rec	ra_customer_trx%ROWTYPE		;
l_trh_rec	ar_transaction_history%ROWTYPE	;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Assignments_Adjustment ()+');
	END IF;

	/*------------------------------------------------------+
        |  For each assignment, non accounting adjustment	|
 	|  is reversed through the adjustment API		|
        +-------------------------------------------------------*/

	FOR  assignment_rec  IN  assignment_cur LOOP

		IF (p_acceptance_flag = 'N')
		THEN

			Reverse_Adjustment (assignment_rec.br_adjustment_id, p_trh_rec, NULL);

			/*----------------------------------------------+
        		|   Removes the Adjustment ID in the Assignment |
			|   Information 				|
	        	+-----------------------------------------------*/


			arp_ctl_pkg.lock_p (assignment_rec.customer_trx_line_id);

			UPDATE	ra_customer_trx_lines
			SET	br_adjustment_id   	=	NULL
			WHERE	customer_trx_line_id 	=	assignment_rec.customer_trx_line_id;


			/*----------------------------------------------+
	       		|  If the exchanged transaction is a BR, create	|
			|  an history record for the exchanged BR	|
        		+-----------------------------------------------*/

			arp_ps_pkg.fetch_p (assignment_rec.br_ref_payment_schedule_id, l_ps_rec);

			IF 	(AR_BILLS_CREATION_VAL_PVT.Is_Transaction_BR (l_ps_rec.cust_trx_type_id))
			THEN

				ARP_CT_PKG.fetch_p (l_trx_rec, assignment_rec.br_ref_customer_trx_id);

				l_trh_rec.customer_trx_id	:=	assignment_rec.br_ref_customer_trx_id;
				ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

				-- Fetch the new status and new event of the BR
				AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
					p_trx_rec	=>	l_trx_rec		,
					p_action        =>	C_EXCHANGE_UNCOMPLETE	,
					p_new_status	=>	l_trh_rec.status	,
					p_new_event	=>	l_trh_rec.event		);

				l_trh_rec.transaction_history_id:=	NULL		;
				l_trh_rec.current_record_flag	:=  	'Y'		;
				l_trh_rec.prv_trx_history_id	:=  	NULL		;
				l_trh_rec.posting_control_id    := 	-3           	;
				l_trh_rec.gl_posted_date        :=  	NULL        	;
				l_trh_rec.first_posted_record_flag  := 	'N'		;
				l_trh_rec.created_from		:=	'ARBRMAIB'	;
				l_trh_rec.postable_flag		:=	'N'		;
				l_trh_rec.current_accounted_flag:=  	'N'		;

				arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
											 l_trh_rec.transaction_history_id);
			END IF;

		ELSE

			update_reserved_columns (assignment_rec.br_ref_payment_schedule_id, NULL, NULL);
		END IF;


	END LOOP;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Assignments_Adjustment ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Assignments_Adjustment () ');
		   arp_util.debug('Reverse_Assignments_Adjustment: ' || 'p_customer_trx_id : ' || p_trh_rec.customer_trx_id);
		   arp_util.debug('Reverse_Assignments_Adjustment: ' || 'p_acceptance_flag : ' || p_acceptance_flag);
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		RAISE;

END Reverse_Assignments_Adjustment;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Find_Last_Receipt				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Find the last receipt applied on the BR					|
 |										|
 +==============================================================================*/


PROCEDURE Find_Last_Receipt (	p_customer_trx_id  IN 	ra_customer_trx.customer_trx_id%TYPE	,
				p_cash_receipt_id  OUT NOCOPY	ar_cash_receipts.cash_receipt_id%TYPE	)

IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Receipt ()+');
	END IF;

	SELECT	cash_receipt_id
	INTO	p_cash_receipt_id
	FROM	ar_receivable_applications
	where	receivable_application_id = (SELECT 	MAX(receivable_application_id)
					     FROM	ar_receivable_applications
					     WHERE	applied_customer_trx_id = p_customer_trx_id
					     AND	status = 'APP'	);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Receipt ()-');
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Receipt () ');
		   arp_util.debug ('Find_Last_Receipt: ' || 'No receipt was found for the BR');
		END IF;
		RAISE;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Receipt () ');
		   arp_util.debug('Find_Last_Receipt: ' || 'p_customer_trx_id : ' || p_customer_trx_id);
		END IF;
		RAISE;

END Find_Last_Receipt;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Find_Last_STD				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Find the last STD application on the BR					|
 |										|
 +==============================================================================*/


PROCEDURE Find_Last_STD ( p_customer_trx_id  		IN 	ra_customer_trx.customer_trx_id%TYPE	,
			  p_cash_receipt_id  		OUT NOCOPY	ar_cash_receipts.cash_receipt_id%TYPE	,
			  p_receivable_application_id 	OUT NOCOPY	ar_receivable_applications.receivable_application_id%TYPE)

IS

CURSOR	last_std_application_cur	IS
	SELECT	receivable_application_id, cash_receipt_id
	FROM	ar_receivable_applications
	WHERE	link_to_customer_trx_id		=	p_customer_trx_id
	AND	status				=	'ACTIVITY'
	AND	applied_payment_schedule_id	=	-2
	AND	display				=	'Y'
	ORDER 	BY	receivable_application_id 	DESC;

last_std_application_rec		last_std_application_cur%ROWTYPE;


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_STD ()+');
	END IF;

	/*-----------------------------------------------+
        |   Fetch last Short Term Debt Application	 |
        +------------------------------------------------*/

	OPEN	last_std_application_cur;
	FETCH	last_std_application_cur	INTO	last_std_application_rec;

	IF	(last_std_application_cur%NOTFOUND)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Find_Last_STD: ' || '>>>>>>>>>> Last Short Term Debt Application could not be found');
		END IF;
		CLOSE	last_std_application_cur;
		APP_EXCEPTION.raise_exception;
	END IF;

	p_cash_receipt_id		:=	last_std_application_rec.cash_receipt_id;
	p_receivable_application_id	:=	last_std_application_rec.receivable_application_id;

	CLOSE	last_std_application_cur;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_STD ()-');
	END IF;

EXCEPTION

	WHEN 	OTHERS 		THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_STD : ' || SQLERRM);
		END IF;
		IF	(last_std_application_cur%ISOPEN)
		THEN
			CLOSE	last_std_application_cur;
		END IF;
		RAISE;

END Find_Last_STD;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Reverse_Receipt				                        	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Reverses a receipt with the receipt API					|
 |										|
 +==============================================================================*/


PROCEDURE Reverse_Receipt (	p_trh_rec   		IN  	ar_transaction_history%ROWTYPE		,
				p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
				p_reversal_reason	IN	VARCHAR2	 			,
				p_called_from		IN	VARCHAR2				)
IS

l_return_status  	VARCHAR2(1);
l_msg_count      	NUMBER;
l_msg_data       	VARCHAR2(2000);
l_count			NUMBER;
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Receipt ()+');
	END IF;

       /* SSA change */
       l_org_id := p_trh_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_receipt : l_org_return_status <> SUCCESS');
       ELSE
	/*------------------------------------------------------+
        | 	Reverse a receipt using Receipt API 		|
        +-------------------------------------------------------*/

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '--------------------------------------------------------------');
	   arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.Reverse : '		);
	   arp_util.debug(  'p_cash_receipt_id		: ' || p_cash_receipt_id	);
	   arp_util.debug(  'p_reversal_category_code   : ' || 'REV'			);
	   arp_util.debug(  'p_reversal_gl_date         : ' || p_trh_rec.gl_date	);
	   arp_util.debug(  'p_reversal_date            : ' || p_trh_rec.trx_date	);
	   arp_util.debug(  'p_called_from    		: ' || p_called_from		);
	   arp_util.debug(  'p_reversal_reason_code	: ' || p_reversal_reason	);
           arp_util.debug(  'p_org_id                   : ' || to_char(p_trh_rec.org_id));
	   arp_util.debug(  '--------------------------------------------------------------');
	END IF;

	AR_RECEIPT_API_PUB.Reverse (
                                p_api_version                 	=> 	1.0			,
                                p_init_msg_list               	=> 	FND_API.G_TRUE		,
                                x_return_status               	=> 	l_return_status		,
                                x_msg_count                   	=> 	l_msg_count		,
                                x_msg_data                    	=> 	l_msg_data		,
                                p_cash_receipt_id		=> 	p_cash_receipt_id	,
				p_reversal_category_code	=> 	'REV'			,
				p_reversal_gl_date		=>  	p_trh_rec.gl_date	,
				p_reversal_date			=>  	p_trh_rec.trx_date	,
				p_called_from			=>  	p_called_from		,
				p_reversal_reason_code		=>  	p_reversal_reason       ,
                                p_org_id                        =>      p_trh_rec.org_id);


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'REVERSAL RECEIPT API Return status : ' || l_return_status);
	   arp_util.debug (  '                     l_msg_count   : ' || to_char(l_msg_count));
	END IF;


	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Receipt Reversal');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;

		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_REVERSE_REC');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Receipt ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Receipt : ' || SQLERRM);
		   arp_util.debug (  'p_cash_receipt_id : ' || p_cash_receipt_id);
		   arp_util.debug (  'p_reversal_reason : ' || p_reversal_reason);
		   arp_util.debug (  'p_called_from     : ' || p_called_from);
		END IF;
		RAISE;

END Reverse_Receipt;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Unapply_Receipt				                        	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Unapplies a receipt using the receipt API				|
 |										|
 +==============================================================================*/


PROCEDURE Unapply_Receipt (	p_trh_rec   		IN  	ar_transaction_history%ROWTYPE		,
			   	p_ps_id			IN	ar_payment_schedules.payment_schedule_id%TYPE,
			   	p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
				p_called_from		IN	VARCHAR2				)
IS

l_return_status  	VARCHAR2(1);
l_msg_count      	NUMBER;
l_msg_data       	VARCHAR2(2000);
l_count			NUMBER;
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unapply_Receipt ()+');
	END IF;

       /* SSA change */
       l_org_id := p_trh_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unapply_Receipt : l_org_return_status <> SUCCESS');
       ELSE

	/*------------------------------------------------------+
        | 	Unapply a receipt using Receipt API 		|
        +-------------------------------------------------------*/

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '--------------------------------------------------------------');
	   arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.Unapply : '		);
	   arp_util.debug(  'p_cash_receipt_id		     : ' || p_cash_receipt_id);
	   arp_util.debug(  'p_customer_trx_id               : ' || p_trh_rec.customer_trx_id);
	   arp_util.debug(  'p_applied_payment_schedule_id   : ' || p_ps_id);
	   arp_util.debug(  'p_reversal_gl_date              : ' || p_trh_rec.gl_date);
	   arp_util.debug(  'p_called_from    		     : ' || p_called_from);
           arp_util.debug(  'p_org_id                        : ' || to_char(p_trh_rec.org_id));
	   arp_util.debug(  '--------------------------------------------------------------');
	END IF;

	AR_RECEIPT_API_PUB.Unapply (
                                p_api_version                 	=> 	1.0			,
                                p_init_msg_list               	=> 	FND_API.G_TRUE		,
                                x_return_status               	=> 	l_return_status		,
                                x_msg_count                   	=> 	l_msg_count		,
                                x_msg_data                    	=> 	l_msg_data		,
                                p_cash_receipt_id		=> 	p_cash_receipt_id	,
				p_customer_trx_id		=> 	p_trh_rec.customer_trx_id,
				p_applied_payment_schedule_id	=>	p_ps_id			,
				p_reversal_gl_date		=>  	p_trh_rec.gl_date	,
				p_called_from			=>  	p_called_from		,
                                p_org_id                        =>      p_trh_rec.org_id);


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'UNAPPLY RECEIPT API Return status : ' || l_return_status);
	   arp_util.debug (  '                    l_msg_count   : ' || to_char(l_msg_count));
	END IF;


	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Receipt Unapplication');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_UNAPPLY_REC');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unapply_Receipt ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Unapply_Receipt : ' || SQLERRM);
		   arp_util.debug (  'p_cash_receipt_id         : ' || p_cash_receipt_id		);
		   arp_util.debug (  'p_called_from             : ' || p_called_from			);
		   arp_util.debug (  'p_ps_id                   : ' || p_ps_id			);
		   arp_util.debug (  'p_trh_rec.customer_trx_id : ' || p_trh_rec.customer_trx_id	);
		END IF;
		RAISE;

END Unapply_Receipt;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Apply_STD				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Applies the receipt to Short Term Debt					|
 |										|
 +==============================================================================*/


PROCEDURE Apply_STD (	p_customer_trx_id		IN	ra_customer_trx.customer_trx_id%TYPE	,
			p_cash_receipt_id		IN	ar_cash_receipts.cash_receipt_id%TYPE	,
			p_apply_date			IN	DATE					,
			p_apply_gl_date			IN	DATE					)


IS

l_msg_count      			NUMBER;
l_msg_data       			VARCHAR2(2000);
l_return_status  			VARCHAR2(1);

l_receivables_trx_id			ar_receivable_applications.receivables_trx_id%TYPE;
l_cr_rec				ar_cash_receipts%ROWTYPE;

l_secondary_application_ref_id  NUMBER:= NULL;
l_application_ref_type          VARCHAR2(30):= NULL;
l_application_ref_id            NUMBER:= NULL;
l_application_ref_num           VARCHAR2(30);
ln_rec_application_id           ar_receivable_applications.receivable_application_id%type;

l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Apply_STD ()+');
	END IF;


       /* SSA change */
       l_org_id := l_cr_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Apply_STD l_org_return_status <> SUCCESS');
       ELSE

	/*------------------------------------------------------+
        | Fetch the Cash Receipt Information		 	|
        +-------------------------------------------------------*/

	l_cr_rec.cash_receipt_id	:=	p_cash_receipt_id;

	arp_cash_receipts_pkg.fetch_p (l_cr_rec);


	/*------------------------------------------------------+
        | Fetch the Receivables activity used for STD	 	|
        +-------------------------------------------------------*/

	SELECT 	br_std_receivables_trx_id
	INTO 	l_receivables_trx_id
	FROM 	ar_receipt_method_accounts
	WHERE 	remit_bank_acct_use_id = l_cr_rec.remit_bank_acct_use_id
	AND	receipt_method_id = l_cr_rec.receipt_method_id;


	/*------------------------------------------------------+
        | Apply receipt to Short Term Debt using Receipt API 	|
        +-------------------------------------------------------*/

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '--------------------------------------------------------------');
	   arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.Activity_Application : ');
	   arp_util.debug(  'p_cash_receipt_id		: ' || p_cash_receipt_id);
	   arp_util.debug(  'p_amount_applied           : ' || l_cr_rec.amount);
	   arp_util.debug(  'p_applied_payment_schedule : ' || '-2');
	   arp_util.debug(  'p_link_to_customer_trx_id  : ' || p_customer_trx_id);
	   arp_util.debug(  'p_receivables_trx_id	: ' || l_receivables_trx_id);
	   arp_util.debug(  'p_apply_date               : ' || p_apply_date);
	   arp_util.debug(  'p_apply_gl_date            : ' || p_apply_gl_date);
           arp_util.debug(  'p_org_id                   : ' || to_char(l_cr_rec.org_id));
	   arp_util.debug(  '--------------------------------------------------------------');
	END IF;

	ar_receipt_api_pub.activity_application(
                      	p_api_version                 	=> 1.0,
			p_init_msg_list			=> FND_API.G_TRUE,
                        x_return_status               	=> l_return_status,
                        x_msg_count                   	=> l_msg_count,
                        x_msg_data                    	=> l_msg_data,
		  	p_cash_receipt_id		=> p_cash_receipt_id,
                        p_amount_applied              	=> l_cr_rec.amount,
			p_applied_payment_schedule_id	=> -2,
			p_link_to_customer_trx_id	=> p_customer_trx_id,
			p_receivables_trx_id		=> l_receivables_trx_id	,
			p_apply_date			=> p_apply_date,
			p_apply_gl_date			=> p_apply_gl_date,
                        p_secondary_application_ref_id  => l_secondary_application_ref_id,
                        p_application_ref_type          => l_application_ref_type,
                        p_application_ref_id            => l_application_ref_id,
                        p_application_ref_num           => l_application_ref_num,
	                p_receivable_application_id     => ln_rec_application_id,
                        p_org_id                        => l_cr_rec.org_id);


	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during SHORT TERM DEBT APPLICATION');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_APPLY_REC');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Apply_STD ()-');
	END IF;

EXCEPTION
	WHEN 	OTHERS 		THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Apply_STD : ' || SQLERRM);
		END IF;
		RAISE;

END Apply_STD;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Unapply_STD				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Unapply the receipt from STD						|
 |										|
 +==============================================================================*/


PROCEDURE Unapply_STD (	p_trh_rec		IN	ar_transaction_history%ROWTYPE		,
			p_called_from		IN	VARCHAR2				,
			p_cash_receipt_id	OUT NOCOPY	ar_cash_receipts.cash_receipt_id%TYPE	)

IS


l_receivable_application_id		ar_receivable_applications.receivable_application_id%TYPE;

l_msg_count      			NUMBER;
l_msg_data       			VARCHAR2(2000);
l_return_status  			VARCHAR2(1);
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unapply_STD ()+');
	END IF;

       /* SSA change */
       l_org_id := p_trh_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unapply_STD : l_org_return_status <> SUCCESS');
       ELSE

	/*-----------------------------------------------+
        |   Fetch last Short Term Debt Application	 |
        +------------------------------------------------*/

	Find_last_STD (p_trh_rec.customer_trx_id, p_cash_receipt_id, l_receivable_application_id);


	/*-----------------------------------------------+
        | Unapply from Short Term Debt using Receipt API |
        +------------------------------------------------*/

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '----------------------------------------------------------------');
	   arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.ACTIVITY_UNAPPLICATION : ');
	   arp_util.debug(  'p_cash_receipt_id		: ' || p_cash_receipt_id);
	   arp_util.debug(  'p_receivable_application_id: ' || l_receivable_application_id);
	   arp_util.debug(  'p_reversal_gl_date		: ' || p_trh_rec.gl_date);
	   arp_util.debug(  'p_called_from		: ' || p_called_from);
           arp_util.debug(  'p_org_id                   : ' || to_char(p_trh_rec.org_id));
	   arp_util.debug(  '----------------------------------------------------------------');
	END IF;

	AR_RECEIPT_API_PUB.Activity_Unapplication(
                     	p_api_version                 	=> 	1.0		,
			p_init_msg_list			=> 	FND_API.G_TRUE	,
                        x_return_status               	=> 	l_return_status	,
                        x_msg_count                   	=> 	l_msg_count	,
                        x_msg_data                    	=> 	l_msg_data	,
		  	p_cash_receipt_id		=> 	p_cash_receipt_id,
			p_receivable_application_id	=>	l_receivable_application_id,
			p_reversal_gl_date		=>	p_trh_rec.gl_date,
			p_called_from			=>	p_called_from,
                        p_org_id                        =>      p_trh_rec.org_id);


	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during SHORT TERM DEBT UNAPPLICATION');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_UNAPPLY_REC');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unapply_STD ()-');
	END IF;

EXCEPTION
	WHEN 	OTHERS 		THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Unapply_STD : ' || SQLERRM);
		END IF;
		RAISE;

END Unapply_STD;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Unpaid					                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    BR - Unpaid								|
 |										|
 +==============================================================================*/

PROCEDURE Unpaid    (	p_trh_rec   		IN OUT NOCOPY	ar_transaction_history%ROWTYPE		,
			p_ps_id			IN	ar_payment_schedules.payment_schedule_id%TYPE,
			p_remittance_batch_id 	IN	ra_customer_trx.remittance_batch_id%TYPE,
			p_unpaid_reason		IN	VARCHAR2				)
IS

l_adj_id			ar_adjustments.adjustment_id%TYPE	;
l_batch_rec			ar_batches%ROWTYPE			;
l_called_from			VARCHAR2(30)	:=	NULL		;
l_cash_receipt_id		ar_cash_receipts.cash_receipt_id%TYPE	;
l_receivable_application_id	ar_receivable_applications.receivable_application_id%TYPE;
l_prev_trh_rec			AR_TRANSACTION_HISTORY%ROWTYPE		;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unpaid ()+');
	END IF;

	-- Fetch the remittance method if it exists

	IF	(p_remittance_batch_id IS NOT NULL)
	THEN

		arp_cr_batches_pkg.fetch_p  (p_remittance_batch_id, l_batch_rec);

		IF	(l_batch_rec.remit_method_code = C_STANDARD)
		THEN
			l_called_from	:=	C_BR_REMITTED;

		ELSIF	(l_batch_rec.remit_method_code = C_FACTORING AND l_batch_rec.with_recourse_flag = 'Y')
		THEN
			l_called_from	:=	C_BR_FACTORED_RECOURSE;

		ELSIF	(l_batch_rec.remit_method_code = C_FACTORING AND l_batch_rec.with_recourse_flag = 'N')
		THEN
			l_called_from	:=	C_BR_FACTORED;
		END IF;
	END IF;



	--  Fetch the previous relevant status of the BR

	l_prev_trh_rec.transaction_history_id	:=	p_trh_rec.prv_trx_history_id;

	AR_BILLS_MAINTAIN_STATUS_PUB.Find_Last_Relevant_trh (l_prev_trh_rec);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'Previous Relevant Status : ' || l_prev_trh_rec.status);
	END IF;



	/*----------------------------------------------+
        |   BR Pending Remittance is Unpaid	OR	|
	|   BR Standard Remitted is Unpaid		|
        +-----------------------------------------------*/

	IF  	(p_trh_rec.status = C_PENDING_REMITTANCE)
	OR	(p_trh_rec.status = C_REMITTED)
	THEN
		update_reserved_columns (p_ps_id, NULL , NULL);
		p_trh_rec.postable_flag		:=	'Y';
		p_trh_rec.current_accounted_flag:=	'Y';


	/*----------------------------------------------+
        |   Protested BR is Unpaid			|
        +-----------------------------------------------*/

	ELSIF	(p_trh_rec.status = C_PROTESTED)
	THEN
		p_trh_rec.postable_flag		:=	'N';
		p_trh_rec.current_accounted_flag:=	'N';


	/*----------------------------------------------+
        |  BR Endorsed and Closed is Unpaid		|
	+-----------------------------------------------*/

	ELSIF	(p_trh_rec.status = C_CLOSED) 	AND   (l_prev_trh_rec.status = C_ENDORSED)
	THEN

		/*----------------------------------------------+
	        |   Reverse the adjustment which closed the BR	|
	        +-----------------------------------------------*/

		Find_Last_Adjustment (p_trh_rec.customer_trx_id, l_adj_id);
		Reverse_Adjustment   (l_adj_id, p_trh_rec, NULL);
		p_trh_rec.postable_flag		:=	'Y';
		p_trh_rec.current_accounted_flag:=	'Y';



	/*----------------------------------------------+
        |   BR Remitted And Closed is Unpaid       OR	|
	|   BR Factored And Closed is Unpaid       OR	|
	|   BR Paid by a single Receipt is Unpaid	|
        +-----------------------------------------------*/

	ELSIF	(p_trh_rec.status = C_CLOSED)	AND
		(p_trh_rec.event  = C_CLOSED	OR	p_trh_rec.event = C_RISK_ELIMINATED)
	THEN

		/*----------------------------------------------+
	        |   Reverse the receipt which paid the BR	|
	        +-----------------------------------------------*/

		Find_Last_Receipt (p_trh_rec.customer_trx_id, l_cash_receipt_id);
		Reverse_Receipt   (p_trh_rec, l_cash_receipt_id, p_unpaid_reason, l_called_from);
		p_trh_rec.postable_flag		:=	'Y';
		p_trh_rec.current_accounted_flag:=	'Y';


	/*----------------------------------------------+
	|   BR Matured Pend Risk Elim is Unpaid	   	|
        +-----------------------------------------------*/

	ELSIF	(p_trh_rec.status = C_MATURED_PEND_RISK_ELIM)
	THEN

		/*----------------------------------------------+
	        |   Unapply the receipt from Short Term Debt	|
		|   And Reverse the receipt 			|
	        +-----------------------------------------------*/

		Find_Last_STD     (p_trh_rec.customer_trx_id, l_cash_receipt_id, l_receivable_application_id);
		Reverse_Receipt   (p_trh_rec, l_cash_receipt_id, p_unpaid_reason, l_called_from);
		update_reserved_columns (p_ps_id, NULL , NULL);
		p_trh_rec.postable_flag		:=	'Y';
		p_trh_rec.current_accounted_flag:=	'Y';



	/*----------------------------------------------+
        |  BR Endorsed is Unpaid			|
	+-----------------------------------------------*/

	ELSIF	(p_trh_rec.status = C_ENDORSED)
	THEN

		/*----------------------------------------------+
	        |   Reject the adjustment created for the BR	|
	        +-----------------------------------------------*/

		Find_Last_Adjustment (p_trh_rec.customer_trx_id, l_adj_id);
		Modify_Adjustment    (l_adj_id, 'R');
		update_reserved_columns (p_ps_id, NULL , NULL);
		p_trh_rec.postable_flag		:=	'Y';
		p_trh_rec.current_accounted_flag:=	'Y';

	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Invalid Action - Case not implemented ');
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_ACTION_FORBIDDEN' );
		FND_MESSAGE.Set_token   ( 'ACTION', C_UNPAID);
		app_exception.raise_exception;

	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Unpaid ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Unpaid () ');
		END IF;
		RAISE;

END Unpaid;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Factore_Recourse				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    BR - Factore with Recourse is approved :					|
 |	 Create a receipt and apply it to Short Term Debt			|
 |										|
 +==============================================================================*/


PROCEDURE Factore_Recourse (	p_batch_rec	IN	ar_batches%ROWTYPE		,
				p_ps_rec	IN	ar_payment_schedules%ROWTYPE	,
				p_trh_rec	IN	ar_transaction_history%ROWTYPE	)

IS

l_cr_id          			NUMBER;
l_count          			NUMBER;
l_msg_count      			NUMBER;
l_msg_data       			VARCHAR2(2000);
l_return_status  			VARCHAR2(1);

l_receipt_number 			VARCHAR2(30)	:=	NULL;
l_receipt_inherit_inv_num_flag		VARCHAR2(1);

l_called_from				VARCHAR2(30)	:=	C_BR_FACTORED_RECOURSE;
l_exch_rate 				NUMBER;

l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Factore_Recourse ()+');
	END IF;


       /* SSA change */
       l_org_id := p_ps_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Factore_Recourse : l_org_return_status <> SUCCESS');
       ELSE

	/*-----------------------------------------------+
        |   Check if the receipt number is inherited	 |
	|   from the BR. If not inherited, the receipt 	 |
	|   API will default it from sequence.		 |
        +------------------------------------------------*/

	SELECT	receipt_inherit_inv_num_flag
	INTO	l_receipt_inherit_inv_num_flag
	FROM	AR_RECEIPT_METHODS
	WHERE	receipt_method_id	=	p_batch_rec.receipt_method_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'Receipt_inherit_inv_num_flag : ' || l_receipt_inherit_inv_num_flag);
	END IF;

	IF	(l_receipt_inherit_inv_num_flag 	=	'Y')
	THEN
		l_receipt_number := p_ps_rec.trx_number;
	END IF;


	/*-----------------------------------------------+
        |   Creation of the Receipt using the Receipt API|
        +------------------------------------------------*/
        -- bug 2649369 : when rate type is corporate, null out rate, as Receipt API expects none to be passed
        -- bug 3506385/3572968 : pass rate only when exchange_rate_type = 'User'
        -- this is the only case where Receipt API expects a rate

        if p_ps_rec.exchange_rate_type <> 'User' then
           l_exch_rate := null;
        else
           l_exch_rate := p_ps_rec.exchange_rate;
        end if;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug( '----------------------------------------------------------------');
           arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.CREATE_CASH : ');
           arp_util.debug('p_currency_code                 : ' || p_ps_rec.invoice_currency_code);
           arp_util.debug('p_exchange_rate_type            : ' || p_ps_rec.exchange_rate_type);
           arp_util.debug('p_exchange_rate                 : ' || l_exch_rate);
           arp_util.debug('p_exchange_rate_date            : ' || p_ps_rec.exchange_date);
           arp_util.debug('p_remittance_bank_account_id    : ' || p_batch_rec.remit_bank_acct_use_id);
           arp_util.debug('p_amount                        : ' || p_ps_rec.amount_due_original);
           arp_util.debug('p_receipt_method_id             : ' || p_batch_rec.receipt_method_id);
           arp_util.debug('p_receipt_number                : ' || l_receipt_number);
           arp_util.debug('p_customer_id                   : ' || p_ps_rec.customer_id);
           arp_util.debug('p_called_from                   : ' || l_called_from);
           arp_util.debug('p_receipt_date                  : ' || p_batch_rec.batch_date);
           arp_util.debug('p_gl_date                       : ' || p_batch_rec.gl_date);
           arp_util.debug('p_cr_id                         : ' || l_cr_id);
           arp_util.debug('p_org_id                        : ' || p_ps_rec.org_id);
           arp_util.debug('----------------------------------------------------------------');
        END IF;

	ar_receipt_api_pub.create_cash(
                       	p_api_version                 	=>  	1.0				,
                        p_init_msg_list               	=>  	FND_API.G_TRUE			,
                        x_return_status               	=>  	l_return_status			,
                        x_msg_count                   	=>  	l_msg_count			,
                        x_msg_data                    	=>  	l_msg_data			,
                        p_currency_code               	=>  	p_ps_rec.invoice_currency_code	,
			p_exchange_rate_type          	=>  	p_ps_rec.exchange_rate_type	,
                        p_exchange_rate               	=>  	l_exch_rate			,
			p_exchange_rate_date 		=> 	p_ps_rec.exchange_date		,
			p_remittance_bank_account_id  	=>  	p_batch_rec.remit_bank_acct_use_id,
                        p_amount                      	=>  	p_ps_rec.amount_due_original 	,
			p_receipt_method_id		=>  	p_batch_rec.receipt_method_id	,
                        p_receipt_number              	=>  	l_receipt_number               	,
                        p_customer_id                 	=>  	p_ps_rec.customer_id        	,
			p_called_from			=>  	l_called_from			,
			p_receipt_date			=>  	p_batch_rec.batch_date		,
			p_gl_date			=>  	p_batch_rec.gl_date		,
                        p_cr_id                       	=>  	l_cr_id                         ,
                        p_org_id                        =>      p_ps_rec.org_id);


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  'Cash Receipt Id created  : ' || l_cr_id);
	   arp_util.debug(  'Return status            : ' || l_return_status);
	END IF;

	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during receipt creation');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_CREATE_REC');
			app_exception.raise_exception;
		END IF;

	END IF;


	/*-----------------------------------------------+
        |   Apply the receipt to Short Term Debt	 |
        +------------------------------------------------*/

	Apply_STD (p_ps_rec.customer_trx_id, l_cr_id, p_batch_rec.batch_date, p_batch_rec.gl_date);


	/*----------------------------------------------+
	|  UPD Cash Receipt History with Batch ID	|
	+-----------------------------------------------*/


	/* Bug 1398843 */
	arp_br_remit_batches.update_br_remit_batch_to_crh(l_cr_id,p_batch_rec.batch_id);

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Factore_Recourse ()-');
        END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Factore_Recourse : ' || SQLERRM);
		END IF;
		RAISE;

END Factore_Recourse;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Factore_Without_Recourse			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    BR - Factore without Recourse is approved	:				|
 |    Create a receipt and apply it to the BR					|
 |										|
 +==============================================================================*/


PROCEDURE Factore_Without_Recourse (	p_batch_rec	IN	ar_batches%ROWTYPE		,
					p_ps_rec	IN	ar_payment_schedules%ROWTYPE	)
IS

l_cr_id          			NUMBER;
l_count          			NUMBER;
l_msg_count      			NUMBER;
l_msg_data       			VARCHAR2(2000);
l_return_status  			VARCHAR2(1);

l_receipt_number 			VARCHAR2(20)	:=	NULL;
l_receipt_inherit_inv_num_flag		VARCHAR2(1);
l_exch_rate				NUMBER;
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Factore_Without_Recourse ()+');
	END IF;

       /* SSA change */
       l_org_id := p_ps_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Factore_Without_Recourse : l_org_return_status <> SUCCESS');
       ELSE

	/*-----------------------------------------------+
        |   Check if the receipt number is inherited	 |
	|   from the BR. If not inherited, the receipt 	 |
	|   API will default it from sequence.		 |
        +------------------------------------------------*/

	SELECT	receipt_inherit_inv_num_flag
	INTO	l_receipt_inherit_inv_num_flag
	FROM	AR_RECEIPT_METHODS
	WHERE	receipt_method_id	=	p_batch_rec.receipt_method_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug (  'Receipt_inherit_inv_num_flag : ' || l_receipt_inherit_inv_num_flag);
	END IF;

	IF	(l_receipt_inherit_inv_num_flag 	=	'Y')
	THEN
		l_receipt_number := p_ps_rec.trx_number;
	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '----------------------------------------------------------------');
	   arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.CREATE_AND_APPLY : ');
	   arp_util.debug(  'p_applied_payment_schedule_id	: ' || p_ps_rec.payment_schedule_id  );
	   arp_util.debug(  'p_amount                	: ' || p_ps_rec.amount_due_remaining);
	   arp_util.debug(  'p_currency_code         	: ' || p_ps_rec.invoice_currency_code);
	   arp_util.debug(  'p_exchange_rate		: ' || p_ps_rec.exchange_rate);
	   arp_util.debug(  'p_receipt_number		: ' || l_receipt_number);
	   arp_util.debug(  'p_receipt_method_id	: ' || p_batch_rec.receipt_method_id);
	   arp_util.debug(  'p_customer_id    		: ' || p_ps_rec.customer_id);
	   arp_util.debug(  'remit bank account use id	: ' || p_batch_rec.remit_bank_acct_use_id);
	   arp_util.debug(  'p_called_from    		: ' || C_BR_FACTORED);
	   arp_util.debug(  'p_link_to_trx_hist_id	: ' || NULL);
           arp_util.debug(  'p_org_id                   : ' || to_char(p_ps_rec.org_id));
	   arp_util.debug(  '----------------------------------------------------------------');
	END IF;

        -- bug 3506385/3572968 : pass rate ONLY when exchange_rate_type = 'User'
        -- this is the only case where Receipt API expects a rate

        if p_ps_rec.exchange_rate_type <> 'User' then
           l_exch_rate := null;
        else
           l_exch_rate := p_ps_rec.exchange_rate;
        end if;


	AR_RECEIPT_API_PUB.create_and_apply(
                      	p_api_version                 	=>  	1.0				,
                        p_init_msg_list               	=>  	FND_API.G_TRUE			,
                        x_return_status               	=>  	l_return_status			,
                        x_msg_count                   	=>  	l_msg_count			,
                        x_msg_data                    	=>  	l_msg_data			,
                        p_currency_code               	=>  	p_ps_rec.invoice_currency_code	,
                        p_exchange_rate_type          	=>  	p_ps_rec.exchange_rate_type	,
                        p_exchange_rate               	=>  	p_ps_rec.exchange_rate		,
			p_exchange_rate_date 		=> 	p_ps_rec.exchange_date		,
                        p_amount                      	=>  	p_ps_rec.amount_due_remaining 	,
                        p_receipt_number              	=>  	l_receipt_number             	,
			p_receipt_method_id		=>  	p_batch_rec.receipt_method_id	,
                        p_customer_id                 	=>  	p_ps_rec.customer_id          	,
                        p_applied_payment_schedule_id 	=>  	p_ps_rec.payment_schedule_id  	,
                        p_remittance_bank_account_id  	=>  	p_batch_rec.remit_bank_acct_use_id,
			p_called_from			=>  	C_BR_FACTORED			,
			p_link_to_trx_hist_id     	=>  	NULL				,
			p_receipt_date			=>  	p_batch_rec.batch_date		,
			p_gl_date			=>  	p_batch_rec.gl_date		,
			p_apply_date			=> 	p_batch_rec.batch_date		,
			p_apply_gl_date			=>  	p_batch_rec.gl_date		,
                        p_cr_id                       	=>  	l_cr_id                        	,
                        p_org_id                        =>      p_ps_rec.org_id);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  'Cash Receipt Id created  : ' || l_cr_id);
	   arp_util.debug(  'Return status            : ' || l_return_status);
	   arp_util.debug(  'l_msg_count              : ' || to_char(l_msg_count));
	END IF;


	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Receipt Creation and Application');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_CREATE_APPLY_REC');
			app_exception.raise_exception;
		END IF;

	END IF;

	/*----------------------------------------------+
        |  UPD Cash Receipt History with Batch ID       |
        +-----------------------------------------------*/


        /* Bug 1398843 */
        arp_br_remit_batches.update_br_remit_batch_to_crh(l_cr_id,p_batch_rec.batch_id);

        END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Factore_Without_Recourse ()-');
	END IF;

EXCEPTION
	WHEN 	OTHERS 		THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Factore_Without_Recourse : ' || SQLERRM);
		END IF;
		RAISE;

END Factore_Without_Recourse;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Apply_Receipt				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Receipt Application							|
 |										|
 +==============================================================================*/


PROCEDURE Apply_Receipt (p_trh_rec		IN	ar_transaction_history%ROWTYPE		,
			 p_ps_rec		IN	ar_payment_schedules%ROWTYPE		,
			 p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
			 p_called_from		IN	VARCHAR2				)

IS

l_msg_count      			NUMBER;
l_msg_data       			VARCHAR2(2000);
l_return_status  			VARCHAR2(1);
l_move_deferred_tax			VARCHAR2(1);
l_org_return_status                     VARCHAR2(1);
l_org_id                                NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Apply_Receipt ()+');
	END IF;

       /* SSA change */
       l_org_id := p_trh_rec.org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Apply_receipt : l_org_return_status <> SUCCESS');
       ELSE

	/*----------------------------------------------+
        |   Create normal application using Receipt API	|
        +-----------------------------------------------*/


	IF	(p_ps_rec.tax_remaining IS NOT NULL	and	p_ps_rec.tax_remaining <> 0)
	THEN
		l_move_deferred_tax	:=	'Y';
	ELSE
		l_move_deferred_tax	:=	'N';
	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug(  '------------------------------------------------');
	   arp_util.debug(  'PARAMETERS PASSED TO AR_RECEIPT_API_PUB.APPLY  : ');
	   arp_util.debug(  'p_cash_receipt_id		: ' || p_cash_receipt_id);
	   arp_util.debug(  'p_customer_trx_id		: ' || p_trh_rec.customer_trx_id);
	   arp_util.debug(  'p_applied_payment_schedule_id   : ' || p_ps_rec.payment_schedule_id);
	   arp_util.debug(  'p_amount_applied           : ' || p_ps_rec.amount_due_remaining);
	   arp_util.debug(  'p_apply_date  		: ' || p_trh_rec.trx_date);
	   arp_util.debug(  'p_apply_gl_date		: ' || p_trh_rec.gl_date);
	   arp_util.debug(  'p_move_deffered_tax     	: ' || l_move_deferred_tax);
           arp_util.debug(  'p_org_id                   : ' || to_char(p_trh_rec.org_id));
	   arp_util.debug(  '------------------------------------------------');
	END IF;

	AR_RECEIPT_API_PUB.Apply (
                     	p_api_version                 	=> 	1.0				,
			p_init_msg_list			=> 	FND_API.G_TRUE			,
                        x_return_status               	=> 	l_return_status			,
                        x_msg_count                   	=> 	l_msg_count			,
                        x_msg_data                    	=> 	l_msg_data			,
		  	p_cash_receipt_id		=> 	p_cash_receipt_id		,
			p_customer_trx_id		=>	p_trh_rec.customer_trx_id	,
			p_applied_payment_schedule_id   => 	p_ps_rec.payment_schedule_id	,
			p_amount_applied                => 	p_ps_rec.amount_due_remaining	,
			p_apply_date  		        => 	p_trh_rec.trx_date		,
			p_apply_gl_date		        => 	p_trh_rec.gl_date		,
			p_called_from			=>	p_called_from			,
			p_move_deferred_tax    		=> 	l_move_deferred_tax		,
                        p_org_id                        =>      p_trh_rec.org_id);

	IF	(l_return_status <> 'S')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> Problems during Receipt Application');
		   arp_util.debug(  'l_return_status : ' || l_return_status);
		   arp_util.debug(  'l_msg_count     : ' || l_msg_count);
		   arp_util.debug(  'l_msg_data      : ' || l_msg_data);
		END IF;


		IF 	(l_msg_count > 0)
		THEN
			Set_Api_Error;
		ELSE
			FND_MESSAGE.SET_NAME ('AR', 'AR_BR_CANNOT_APPLY_REC');
			app_exception.raise_exception;
		END IF;

	END IF;
        END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Apply_Receipt ()-');
	END IF;

EXCEPTION
	WHEN 	OTHERS 		THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Apply_Receipt : ' || SQLERRM);
		END IF;
		RAISE;

END Apply_Receipt;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    	Link_Application_History 		                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |	Populates LINK_TO_TRX_HIST_ID on the application that closes the 	|
 |	BR at the end of the remittance process (Factore Without Recourse)	|
 |										|
 +==============================================================================*/


PROCEDURE Link_Application_History  (p_trh_rec	IN   ar_transaction_history%ROWTYPE)

IS

CURSOR	last_application_cur	IS
	SELECT	receivable_application_id
	FROM	ar_receivable_applications
	WHERE	applied_customer_trx_id		=	p_trh_rec.customer_trx_id
	AND	status				=	'APP'
	AND	display				=	'Y'
	ORDER 	BY	receivable_application_id 	DESC;

last_application_rec		last_application_cur%ROWTYPE;


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Link_Application_History ()+');
	END IF;

	/*----------------------------------------------+
        |   Fetch last Application	 		|
        +-----------------------------------------------*/

	OPEN	last_application_cur;
	FETCH	last_application_cur	INTO	last_application_rec;

	IF	(last_application_cur%NOTFOUND)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Link_Application_History: ' || '>>>>>>>>>> Last Application could not be found');
		END IF;
		CLOSE	last_application_cur;
		APP_EXCEPTION.raise_exception;
	END IF;

	CLOSE	last_application_cur;


	/*----------------------------------------------+
        |   Populate the LINK_TO_TRX_HIST_ID on the	|
	|   application that closes the BR for Factored |
	|   without Recourse case.			|
        +-----------------------------------------------*/

	ARP_APP_PKG.lock_p (last_application_rec.receivable_application_id);


	/*----------------------------------------------+
        |   Update the LINK_TO_TRX_HIST_ID on the	|
	|   application					|
        +-----------------------------------------------*/

	UPDATE	ar_receivable_applications
	SET	LINK_TO_TRX_HIST_ID		=	p_trh_rec.transaction_history_id
	WHERE	receivable_application_id	=	last_application_rec.receivable_application_id;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_LIB_PVT.Link_Application_History ()-');
	END IF;

EXCEPTION
	WHEN 	OTHERS 		THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_LIB_PVT.Link_Application_History : ' || SQLERRM);
		END IF;
		IF	(last_application_cur%ISOPEN)
		THEN
			CLOSE	last_application_cur;
		END IF;
		RAISE;

END Link_Application_History;


END AR_BILLS_MAINTAIN_LIB_PVT ;

/
