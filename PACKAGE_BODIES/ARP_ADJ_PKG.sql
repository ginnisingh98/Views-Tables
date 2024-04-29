--------------------------------------------------------
--  DDL for Package Body ARP_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADJ_PKG" AS
/* $Header: ARCIADJB.pls 120.7 2006/03/03 22:54:27 hyu ship $*/
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into AR_ADJUSTMENTS table                 |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_adj_rec - Adjustment Record structure                |
 |              OUT:                                                         |
 |                    p_adj_id - Adjustment Id of inserted ar_adjustments row|
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                        05/02/95 - Removed the hardcoded assignment to     |
 |                                   created_from column in insert_p proc.   |
 |                                   It was hard coded as 'ARSUECA'          |
 |                                                                           |
 |                        20-MAR-2000 J Rautiainen                           |
 |                                    Added BR project related column        |
 |                                    LINK_TO_TRX_HIST_ID into the table     |
 |                                    handlers.                              |
 |									     |
 |			  31-OCT-2000 Y Rakotonirainy			     |
 |				      Bug 1243304 : Added columns 	     |
 |				      adj_tax_acct_rule and    		     |
 |				      cons_inv_id into the table handlers.   |
 |                                                                           |
 |  03-MARCH-2006 Herve Yu
 |            Late Charge Project: new columns added for insert_row          |
 |            interest_header_id, interest_line_id                           |
 +===========================================================================*/
PROCEDURE insert_p( p_adj_rec 	IN ar_adjustments%ROWTYPE,
		    p_adj_id      OUT NOCOPY ar_adjustments.adjustment_id%TYPE ) IS
l_adj_id      ar_adjustments.adjustment_id%TYPE;
BEGIN
      arp_standard.debug( '>>>>>>>> arp_adj_pkg.insert_p' );
      --
      SELECT ar_adjustments_s.nextval
      INTO   l_adj_id
      FROM   dual;
      --
      INSERT INTO  ar_adjustments (
 		adjustment_id,
 		acctd_amount,
 		adjustment_type,
 		amount,
 		code_combination_id,
 		created_by,
 		creation_date,
 		gl_date,
 		last_updated_by,
 		last_update_date,
 		set_of_books_id,
 		status,
 		type,
 		created_from,
 		adjustment_number,
 		apply_date,
 		approved_by,
 		associated_cash_receipt_id,
 		automatically_generated,
 		batch_id,
 		chargeback_customer_trx_id,
 		comments,
 		customer_trx_id,
 		customer_trx_line_id,
 		distribution_set_id,
 		freight_adjusted,
 		gl_posted_date,
 		last_update_login,
 		line_adjusted,
 		payment_schedule_id,
 		postable,
 		posting_control_id,
 		reason_code,
 		receivables_charges_adjusted,
 		receivables_trx_id,
 		subsequent_trx_id,
 		tax_adjusted,
 		attribute_category,
 		attribute1,
 		attribute2,
 		attribute3,
 		attribute4,
 		attribute5,
 		attribute6,
 		attribute7,
 		attribute8,
 		attribute9,
 		attribute10,
 		attribute11,
 		attribute12,
 		attribute13,
 		attribute14,
 		attribute15,
 		ussgl_transaction_code,
 		ussgl_transaction_code_context,
 		request_id,
 		program_update_date,
 		program_id,
 		program_application_id,
 		doc_sequence_id,
 		doc_sequence_value,
 		associated_application_id,
                link_to_trx_hist_id,
                adj_tax_acct_rule,
                cons_inv_id
                ,org_id
--{Late Charge Project
,interest_header_id
,interest_line_id )
       VALUES ( l_adj_id,
		p_adj_rec.acctd_amount,
                p_adj_rec.adjustment_type,
                p_adj_rec.amount,
                p_adj_rec.code_combination_id,
                arp_standard.profile.user_id,
                SYSDATE,
                p_adj_rec.gl_date,
                arp_standard.profile.user_id,
                SYSDATE,
                p_adj_rec.set_of_books_id,
                p_adj_rec.status,
                p_adj_rec.type,
                p_adj_rec.created_from,
                ar_adjustment_number_s.nextval,
                p_adj_rec.apply_date,
                p_adj_rec.approved_by,
                p_adj_rec.associated_cash_receipt_id,
                p_adj_rec.automatically_generated,
                p_adj_rec.batch_id,
                p_adj_rec.chargeback_customer_trx_id,
                p_adj_rec.comments,
                p_adj_rec.customer_trx_id,
                p_adj_rec.customer_trx_line_id,
                p_adj_rec.distribution_set_id,
                p_adj_rec.freight_adjusted,
                p_adj_rec.gl_posted_date,
                NVL( arp_standard.profile.last_update_login,
		     p_adj_rec.last_update_login ),
                p_adj_rec.line_adjusted,
                p_adj_rec.payment_schedule_id,
                p_adj_rec.postable,
                p_adj_rec.posting_control_id,
                p_adj_rec.reason_code,
                p_adj_rec.receivables_charges_adjusted,
                p_adj_rec.receivables_trx_id,
                p_adj_rec.subsequent_trx_id,
                p_adj_rec.tax_adjusted,
                p_adj_rec.attribute_category,
                p_adj_rec.attribute1,
                p_adj_rec.attribute2,
                p_adj_rec.attribute3,
                p_adj_rec.attribute4,
                p_adj_rec.attribute5,
                p_adj_rec.attribute6,
                p_adj_rec.attribute7,
                p_adj_rec.attribute8,
                p_adj_rec.attribute9,
                p_adj_rec.attribute10,
                p_adj_rec.attribute11,
                p_adj_rec.attribute12,
                p_adj_rec.attribute13,
                p_adj_rec.attribute14,
                p_adj_rec.attribute15,
                p_adj_rec.ussgl_transaction_code,
                p_adj_rec.ussgl_transaction_code_context,
                NVL( arp_standard.profile.request_id,
                     p_adj_rec.request_id ),
                DECODE( arp_standard.profile.program_id,
                        NULL, NULL,
                        SYSDATE
                      ),
                NVL( arp_standard.profile.program_id, p_adj_rec.program_id ),
                NVL( arp_standard.profile.program_application_id,
		     p_adj_rec.program_application_id ),
                p_adj_rec.doc_sequence_id,
                p_adj_rec.doc_sequence_value,
                p_adj_rec.associated_application_id,
                p_adj_rec.link_to_trx_hist_id,
                p_adj_rec.adj_tax_acct_rule,
                p_adj_rec.cons_inv_id
               ,arp_standard.sysparm.org_id /* SSA changes anuj */
--{Late Charge Project
               ,p_adj_rec.interest_header_id
               ,p_adj_rec.interest_line_id
	       );
    --
   /*-------------------------------------------+
    | Call central MRC library for insertion    |
    | into MRC tables                           |
    +-------------------------------------------*/
--{BUG#4301323
--   ar_mrc_engine.maintain_mrc_data( p_event_mode         => 'INSERT',
--                                    p_table_name         => 'AR_ADJUSTMENTS',
--                                    p_mode               => 'SINGLE',
--                                    p_key_value          => l_adj_id);
--}
    p_adj_id := l_adj_id;
    arp_standard.debug( '<<<<<<<< arp_adj_pkg.insert_p' );
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_adj_pkg.insert_p' );
	    RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row into AR_ADJUSTMENTS table                  |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                    p_adj_rec - Adjustment Record structure                |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 |                        20-MAR-2000 J Rautiainen                           |
 |                                    Added BR project related column        |
 |                                    LINK_TO_TRX_HIST_ID into the table     |
 |                                    handlers.                              |
 |                                                                           |
 |			  31-OCT-2000 Y Rakotonirainy			     |
 |				      Bug 1243304 : Added columns 	     |
 |				      adj_tax_acct_rule and    		     |
 |				      cons_inv_id into the table handlers.   |
 +===========================================================================*/
PROCEDURE update_p( p_adj_rec 	IN AR_ADJUSTMENTS%ROWTYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_adj_pkg.update_p' );
    --
    UPDATE ar_adjustments SET
		acctd_amount = p_adj_rec.acctd_amount,
 		adjustment_type = p_adj_rec.adjustment_type,
 		amount = p_adj_rec.amount,
 		code_combination_id = p_adj_rec.code_combination_id,
 		gl_date = p_adj_rec.gl_date,
 		last_updated_by = arp_standard.profile.user_id,
 		last_update_date = SYSDATE,
 		set_of_books_id = p_adj_rec.set_of_books_id,
 		status = p_adj_rec.status,
 		type = p_adj_rec.type,
 		adjustment_number = p_adj_rec.adjustment_number,
 		apply_date = p_adj_rec.apply_date,
 		approved_by = p_adj_rec.approved_by,
 		associated_cash_receipt_id =
					p_adj_rec.associated_cash_receipt_id,
 		automatically_generated =
					p_adj_rec.automatically_generated,
 		batch_id = p_adj_rec.batch_id,
 		chargeback_customer_trx_id =
					p_adj_rec.chargeback_customer_trx_id,
 		comments = p_adj_rec.comments,
 		customer_trx_id = p_adj_rec.customer_trx_id,
 		customer_trx_line_id = p_adj_rec.customer_trx_line_id,
 		distribution_set_id = p_adj_rec.distribution_set_id,
 		freight_adjusted = p_adj_rec.freight_adjusted,
 		gl_posted_date = p_adj_rec.gl_posted_date,
 		last_update_login = NVL( arp_standard.profile.last_update_login,
					 p_adj_rec.last_update_login ),
 		line_adjusted = p_adj_rec.line_adjusted,
 		payment_schedule_id = p_adj_rec.payment_schedule_id,
 		postable = p_adj_rec.postable,
 		posting_control_id = p_adj_rec.posting_control_id,
 		reason_code = p_adj_rec.reason_code,
 		receivables_charges_adjusted =
					p_adj_rec.receivables_charges_adjusted,
 		receivables_trx_id = p_adj_rec.receivables_trx_id,
 		subsequent_trx_id = p_adj_rec.subsequent_trx_id,
 		tax_adjusted = p_adj_rec.tax_adjusted,
 		attribute_category = p_adj_rec.attribute_category,
 		attribute1 = p_adj_rec.attribute1,
 		attribute2 = p_adj_rec.attribute2,
 		attribute3 = p_adj_rec.attribute3,
 		attribute4 = p_adj_rec.attribute4,
 		attributE5 = p_adj_rec.attribute5,
 		attributE6 = p_adj_rec.attribute6,
 		attributE7 = p_adj_rec.attribute7,
 		attributE8 = p_adj_rec.attribute8,
 		attributE9 = p_adj_rec.attribute9,
 		attributE10 = p_adj_rec.attribute10,
 		attributE11 = p_adj_rec.attribute11,
 		attributE12 = p_adj_rec.attribute12,
 		attributE13 = p_adj_rec.attribute13,
 		attributE14 = p_adj_rec.attribute14,
 		attributE15 = p_adj_rec.attribute15,
 		ussgl_transaction_code =
				p_adj_rec.ussgl_transaction_code,
 		ussgl_transaction_code_context =
				p_adj_rec.ussgl_transaction_code_context,
 		request_id = NVL( arp_standard.profile.request_id,
				  p_adj_rec.request_id ),
 		program_update_date =
				DECODE( arp_standard.profile.program_id,
                                        NULL, NULL,
                                        SYSDATE
                                      ),
 		program_id = NVL( arp_standard.profile.program_id,
				  p_adj_rec.program_id ),
 		program_application_id =
			      NVL( arp_standard.profile.program_application_id,
			   	   p_adj_rec.program_application_id ),
 		doc_sequence_id = p_adj_rec.doc_sequence_id,
 		doc_sequence_value = p_adj_rec.doc_sequence_value,
 		associated_application_id =
					p_adj_rec.associated_application_id,
                link_to_trx_hist_id = p_adj_rec.link_to_trx_hist_id,
                adj_tax_acct_rule = p_adj_rec.adj_tax_acct_rule,
                cons_inv_id = p_adj_rec.cons_inv_id
    WHERE adjustment_id = p_adj_rec.adjustment_id;
    --
   /*----------------------------------------------------+
    |  Call central MRC library for the generic update   |
    |  made above.   This is done here rather then in    |
    |  the generic update as the where clause changes    |
    |  and that information is needed for the MRC engine |
    +----------------------------------------------------*/
--{BUG4301323
--    ar_mrc_engine.maintain_mrc_data(
--                  p_event_mode       => 'UPDATE',
--                  p_table_name       => 'AR_ADJUSTMENTS',
--                  p_mode             => 'SINGLE',
--                  p_key_value        => p_adj_rec.adjustment_id
--                                   );
--}
    --
    arp_standard.debug( '<<<<<<<< arp_adj_pkg.update_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_adj_pkg.update_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_ADJUSTMENTS table                  |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:  							     |
 |		    p_adj_id - Adjustment Id to delete a row from            |
 |		             AR_ADJUSTMENTS                                  |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p( p_adj_id 	IN AR_ADJUSTMENTS.ADJUSTMENT_ID%TYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_adj_pkg.delete_p' );
    --
    DELETE FROM ar_adjustments
    WHERE adjustment_id = p_adj_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
--{BUG4301323
--    ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode => 'DELETE',
--                        p_table_name => 'AR_ADJUSTMENTS',
--                        p_mode       => 'SINGLE',
--                        p_key_value  => p_adj_id);
--}
    --
    arp_standard.debug( '<<<<<<<< arp_adj_pkg.delete_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_adj_pkg.delete_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_ADJUSTMENTS table                      |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                  p_adj_id - Adjustment Id of row to be locked in          |
 |                             AR_ADJUSTMENTS table                          |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p( p_adj_id 	IN AR_ADJUSTMENTS.ADJUSTMENT_ID%TYPE ) IS
l_adj_id		AR_ADJUSTMENTS.ADJUSTMENT_ID%TYPE;
BEGIN
    arp_standard.debug( '>>>>>>>> arp_adj_pkg.lock_p' );
    --
    SELECT adjustment_id
    INTO   l_adj_id
    FROM  ar_adjustments
    WHERE adjustment_id = p_adj_id
    FOR UPDATE OF STATUS NOWAIT;
    --
    arp_standard.debug( '<<<<<<<< arp_adj_pkg.lock_p' );
    EXCEPTION
        WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_adj_pkg.lock_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_ADJUSTMENTS table                  |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                  p_adj_id - Adjustment Id of row to be fetched from       |
 |                             AR_ADJUSTMENTS table                          |
 |              OUT:                                                         |
 |                  p_adj_rec - Adjustment Record structure                  |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p( p_adj_id IN ar_adjustments.adjustment_id%TYPE,
                   p_adj_rec OUT NOCOPY ar_adjustments%ROWTYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_adj_pkg.fetch_p' );
    --
    SELECT *
    INTO   p_adj_rec
    FROM   ar_adjustments
    WHERE  adjustment_id = p_adj_id;
    --
    arp_standard.debug( '<<<<<<<< arp_adj_pkg.fetch_p' );
    EXCEPTION
       WHEN OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_adj_pkg.fetch_p' );
            RAISE;
END;
--
END  ARP_ADJ_PKG;
--

/
