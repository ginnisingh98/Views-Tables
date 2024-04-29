--------------------------------------------------------
--  DDL for Package Body ARP_REVERSE_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_REVERSE_RECEIPT" AS
/* $Header: ARREREVB.pls 120.23.12010000.8 2009/11/06 08:36:16 spdixit ship $*/

/* =======================================================================
 | Global Data Types
 + ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

--
-- Private procedures used by the package
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE validate_args(
			p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
                        p_reversal_category     IN VARCHAR2,
                        p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
                        p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
                        p_reversal_reason_code  IN VARCHAR2 );
--
PROCEDURE update_current_cr_rec(
	    p_cr_rec             IN OUT NOCOPY ar_cash_receipts%ROWTYPE,
            p_reversal_category  IN ar_cash_receipts.reversal_category%TYPE,
            p_reversal_date      IN ar_cash_receipts.reversal_date%TYPE,
            p_reversal_reason_code IN ar_cash_receipts.reversal_reason_code%TYPE,
            p_reversal_comments  IN ar_cash_receipts.reversal_comments%TYPE,
            p_attribute_category IN ar_cash_receipts.attribute_category%TYPE,
            p_attribute1         IN ar_cash_receipts.attribute1%TYPE,
            p_attribute2         IN ar_cash_receipts.attribute2%TYPE,
            p_attribute3         IN ar_cash_receipts.attribute3%TYPE,
            p_attribute4         IN ar_cash_receipts.attribute4%TYPE,
            p_attribute5         IN ar_cash_receipts.attribute5%TYPE,
            p_attribute6         IN ar_cash_receipts.attribute6%TYPE,
            p_attribute7         IN ar_cash_receipts.attribute7%TYPE,
            p_attribute8         IN ar_cash_receipts.attribute8%TYPE,
            p_attribute9         IN ar_cash_receipts.attribute9%TYPE,
            p_attribute10        IN ar_cash_receipts.attribute10%TYPE,
            p_attribute11        IN ar_cash_receipts.attribute11%TYPE,
            p_attribute12        IN ar_cash_receipts.attribute12%TYPE,
            p_attribute13        IN ar_cash_receipts.attribute13%TYPE,
            p_attribute14        IN ar_cash_receipts.attribute14%TYPE,
            p_attribute15        IN ar_cash_receipts.attribute15%TYPE );
--
PROCEDURE update_current_crh_record(
        p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE,
        p_reversal_gl_date IN ar_misc_cash_distributions.gl_date%TYPE,
        p_reversal_date IN ar_misc_cash_distributions.apply_date%TYPE,
        p_crh_id_new IN ar_cash_receipt_history.cash_receipt_history_id%TYPE );
--
PROCEDURE insert_reversal_crh_record(
        p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE,
        p_reversal_gl_date IN ar_misc_cash_distributions.gl_date%TYPE,
        p_reversal_date IN ar_misc_cash_distributions.apply_date%TYPE,
        p_clear_batch_id   IN VARCHAR2,
        p_crh_id OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE
       );
--
PROCEDURE insert_reversal_mcd_record(
        p_mcd_rec IN OUT NOCOPY ar_misc_cash_distributions%ROWTYPE,
        p_reversal_gl_date IN ar_misc_cash_distributions.gl_date%TYPE,
        p_reversal_date IN ar_misc_cash_distributions.apply_date%TYPE );
--
PROCEDURE insert_reversal_dist_rec(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE );
--
FUNCTION check_cb( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE )
                   RETURN BOOLEAN;
--
PROCEDURE modify_update_ps_rec(
                p_cr_id IN ar_payment_schedules.cash_receipt_id%TYPE,
                p_reversal_gl_date IN DATE,
                p_reversal_date IN DATE );
--
PROCEDURE modify_update_bat_rec( p_bat_id       IN ar_batches.batch_id%TYPE,
                       p_cr_amount    IN ar_cash_receipts.amount%TYPE,
                       p_status       IN VARCHAR2 );
--
PROCEDURE validate_dm_reversal_args(
         p_cr_id     IN ar_cash_receipts.cash_receipt_id%TYPE,
         p_cc_id     IN ra_cust_trx_line_gl_dist.code_combination_id%TYPE,
         p_cust_trx_type_id IN ra_cust_trx_types.cust_trx_type_id%TYPE,
         p_reversal_gl_date  IN
                        ar_cash_receipt_history.reversal_gl_date%TYPE,
         p_reversal_date  IN
                        ar_cash_receipts.reversal_date%TYPE,
         p_reversal_reason_code  IN VARCHAR2);
--
--
-- Externally visible procedure
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reverse an receipt   n                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_process_application.reverse - Reverse an application                          |
 |     arp_cash_receipts_pkg.fetch_p - Fetch a record from ar_cash_receipts  |
 |     arp_app_pkg.lock_p  - lock  a record in                  |
 |                                        AR_RECEIVABLE_APPLICATIONS table   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cahs receipt ID                              |
 |                    p_reversal_category - Reversal Category                |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_reversal_reason_code - Reason for reversal           |
 |                    p_reversal_comments - Reversal comments                |
 |                    p_clear_batch_id - Flag to denote if the batch Id      |
 |                                       should be nulled out NOCOPY or not         |
 |                    p_module_name - Name of module that called this proc.  |
 |                    p_module_version - Version of the module that called   |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE reverse (
	p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_reversal_category     IN ar_cash_receipts.reversal_category%TYPE,
	p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
	p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
	p_reversal_reason_code  IN ar_cash_receipts.reversal_reason_code%TYPE,
	p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
	p_clear_batch_id    	IN ar_cash_receipt_history.batch_id%TYPE,
	p_attribute_category	IN ar_cash_receipts.attribute_category%TYPE,
	p_attribute1    	IN ar_cash_receipts.attribute1%TYPE,
	p_attribute2    	IN ar_cash_receipts.attribute2%TYPE,
	p_attribute3    	IN ar_cash_receipts.attribute3%TYPE,
	p_attribute4    	IN ar_cash_receipts.attribute4%TYPE,
	p_attribute5    	IN ar_cash_receipts.attribute5%TYPE,
	p_attribute6    	IN ar_cash_receipts.attribute6%TYPE,
	p_attribute7    	IN ar_cash_receipts.attribute7%TYPE,
	p_attribute8    	IN ar_cash_receipts.attribute8%TYPE,
	p_attribute9    	IN ar_cash_receipts.attribute9%TYPE,
	p_attribute10   	IN ar_cash_receipts.attribute10%TYPE,
	p_attribute11   	IN ar_cash_receipts.attribute11%TYPE,
	p_attribute12   	IN ar_cash_receipts.attribute12%TYPE,
	p_attribute13   	IN ar_cash_receipts.attribute13%TYPE,
	p_attribute14   	IN ar_cash_receipts.attribute14%TYPE,
	p_attribute15   	IN ar_cash_receipts.attribute15%TYPE,
	p_module_name   	IN VARCHAR2,
	p_module_version   	IN VARCHAR2,
	p_crh_id                OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE,
 	p_called_from           IN VARCHAR2 DEFAULT NULL) IS /* jrautiai BR implementation */
--
l_cr_rec	ar_cash_receipts%ROWTYPE;
l_crh_rec_old	ar_cash_receipt_history%ROWTYPE;
l_crh_rec	ar_cash_receipt_history%ROWTYPE;
l_batches_rec	ar_batches%ROWTYPE;
l_mcd_rec 	ar_misc_cash_distributions%ROWTYPE;
/*CCR-add cursor for receipt method pkt */

--
l_crh_id       	ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_ra_id   	ar_receivable_applications.receivable_application_id%TYPE;
l_receivable_application_id ar_receivable_applications.receivable_application_id%TYPE;
l_mcd_id	ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;
l_rm_code	ar_receipt_methods.payment_type_code%TYPE;
l_rt_type	ar_receivables_trx.type%TYPE;

--
l_gl_date_closed   	DATE;
l_actual_date_closed	DATE;

v_credit_card		BOOLEAN;  --CCRR pkt

l_batch_id		ar_batches.batch_id%TYPE;
ln_bal_due_remaining   NUMBER;   /* placeholder for bug 584303 */
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

-- Bug 7241111
  l_llca_exist varchar(1) := 'N';

unapply_netting_err     EXCEPTION;
cancel_refund_err       EXCEPTION;

--
TYPE l_ps_ra_record IS RECORD
    (
     acctd_amount_applied                NUMBER,
     amount_applied                      NUMBER,
     earned_discount_taken		 NUMBER,
     unearned_discount_taken		 NUMBER,
     acctd_earned_discount_taken         NUMBER,
     acctd_unearned_discount_taken       NUMBER,
     line_applied                        NUMBER,
     tax_applied                         NUMBER,
     freight_applied                     NUMBER,
     receivables_charges_applied         NUMBER
    );
--
/* 08-AUG-2000 J Rautiainen BR Implementation */
 CURSOR ar_ra_C( p_cr_id ar_cash_receipts.cash_receipt_id%TYPE ) IS
       SELECT receivable_application_id
            , receivables_trx_id
	    , applied_payment_schedule_id
	    , application_ref_id
       FROM   ar_receivable_applications
       WHERE  cash_receipt_id = p_cr_id
       AND    ( (
                 status||'' in ('APP', 'ACC','ACTIVITY','OTHER ACC')
                 AND  display = 'Y'
                )
                OR
               (
                status||'' in ('UNAPP', 'UNID')
               )
             )
        AND   reversal_gl_date is NULL
        ORDER BY decode(status,'APP',1,'ACTIVITY',2,'ACC',3,'OTHER ACC',4,'UNID',5,'UNAPP',6); --VAT 11.5 for pairing UNAPP records
--
CURSOR ar_mcd_C( p_cr_id ar_cash_receipts.cash_receipt_id%TYPE ) IS
       SELECT *
       FROM   ar_misc_cash_distributions
       WHERE  cash_receipt_id = p_cr_id
       AND    reversal_gl_date is null;
--
/*CCRR- need to find the application id associated with the Negative Misc receipt pkt*/
/* bug3635777 : Added table ar_cash_receipts to avoid FTS on ra table */

CURSOR ar_rc_rec( p_cr_id ar_cash_receipts.cash_receipt_id%TYPE ) IS
       SELECT ra.receivable_application_id
       FROM   ar_receivable_applications ra ,ar_cash_receipts cr
       WHERE  cr.reference_id = ra.cash_receipt_id
       AND    cr.cash_receipt_id = p_cr_id
       AND    ra.application_ref_id = p_cr_id
       AND    ra.application_ref_type = 'MISC_RECEIPT';

--
/* CCRR-need to find the receipt payment type code to determine if the MISC receipt is of type Credit_card  pkt*/
CURSOR ar_rm_C(p_receipt_method_id ar_receipt_methods.receipt_method_id%TYPE) is
   Select payment_channel_code
    FROM ar_receipt_methods
    where receipt_method_id = p_receipt_method_id;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('validate_args: ' ||  'arp_reverse_receipt.reverse() +');
       arp_standard.debug('validate_args: ' ||  'cr_id = '||to_char( p_cr_id ) );
    END IF;
    -- Validate input arguments
    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
         validate_args( p_cr_id, p_reversal_category,
                        p_reversal_gl_date, p_reversal_date,
                        p_reversal_reason_code );
    END IF;
    --
    -- Populate the ar_cash_receipts record from
    -- ar_cash_receipts table. Use cash_receipt_id for selection.
    --
    l_cr_rec.cash_receipt_id := p_cr_id;
    arp_cash_receipts_pkg.fetch_p( l_cr_rec );
    --
    -- Check if CB is associated with the application and if CB has a activity
    -- or is posted. If so, return error message.
    --
    IF ( check_cb( p_cr_id ) = FALSE ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('validate_args: ' ||  'Check CB Failed' );
         END IF;
         FND_MESSAGE.set_name('AR', 'AR_DEBIT_REVERSE');
	 APP_EXCEPTION.raise_exception;
    END IF ;
    --
    --

    --{
    -- Bug 7241111 to retain the old application record under activity details

     begin
       select 'Y' into l_llca_exist
       from ar_activity_details
       where cash_receipt_id = p_cr_id
	     and nvl(CURRENT_ACTIVITY_FLAG,'Y') = 'Y';

     exception
       when too_many_rows then
          l_llca_exist := 'Y';
       when no_data_found then
          l_llca_exist := 'N';
       when others then
          l_llca_exist := 'N';
      end;



IF NVL(l_llca_exist,'N') = 'Y' THEN

	INSERT INTO AR_ACTIVITY_DETAILS(
					CASH_RECEIPT_ID,
					CUSTOMER_TRX_LINE_ID,
					ALLOCATED_RECEIPT_AMOUNT,
					AMOUNT,
					TAX,
					FREIGHT,
					CHARGES,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LINE_DISCOUNT,
					TAX_DISCOUNT,
					FREIGHT_DISCOUNT,
					LINE_BALANCE,
					TAX_BALANCE,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_LOGIN,
					COMMENTS,
					APPLY_TO,
					ATTRIBUTE1,
					ATTRIBUTE2,
					ATTRIBUTE3,
					ATTRIBUTE4,
					ATTRIBUTE5,
					ATTRIBUTE6,
					ATTRIBUTE7,
					ATTRIBUTE8,
					ATTRIBUTE9,
					ATTRIBUTE10,
					ATTRIBUTE11,
					ATTRIBUTE12,
					ATTRIBUTE13,
					ATTRIBUTE14,
					ATTRIBUTE15,
					ATTRIBUTE_CATEGORY,
					GROUP_ID,
					REFERENCE1,
					REFERENCE2,
					REFERENCE3,
					REFERENCE4,
					REFERENCE5,
					OBJECT_VERSION_NUMBER,
					CREATED_BY_MODULE,
					SOURCE_ID,
					SOURCE_TABLE,
					LINE_ID,
					CURRENT_ACTIVITY_FLAG)
				SELECT
					LLD.CASH_RECEIPT_ID,
					LLD.CUSTOMER_TRX_LINE_ID,
					LLD.ALLOCATED_RECEIPT_AMOUNT*-1,
					LLD.AMOUNT*-1,
					LLD.TAX*-1,
					LLD.FREIGHT*-1,
					LLD.CHARGES*-1,
					LLD.LAST_UPDATE_DATE,
					LLD.LAST_UPDATED_BY,
					LLD.LINE_DISCOUNT,
					LLD.TAX_DISCOUNT,
					LLD.FREIGHT_DISCOUNT,
					LLD.LINE_BALANCE,
					LLD.TAX_BALANCE,
					LLD.CREATION_DATE,
					LLD.CREATED_BY,
					LLD.LAST_UPDATE_LOGIN,
					LLD.COMMENTS,
					LLD.APPLY_TO,
					LLD.ATTRIBUTE1,
					LLD.ATTRIBUTE2,
					LLD.ATTRIBUTE3,
					LLD.ATTRIBUTE4,
					LLD.ATTRIBUTE5,
					LLD.ATTRIBUTE6,
					LLD.ATTRIBUTE7,
					LLD.ATTRIBUTE8,
					LLD.ATTRIBUTE9,
					LLD.ATTRIBUTE10,
					LLD.ATTRIBUTE11,
					LLD.ATTRIBUTE12,
					LLD.ATTRIBUTE13,
					LLD.ATTRIBUTE14,
					LLD.ATTRIBUTE15,
					LLD.ATTRIBUTE_CATEGORY,
					LLD.GROUP_ID,
					LLD.REFERENCE1,
					LLD.REFERENCE2,
					LLD.REFERENCE3,
					LLD.REFERENCE4,
					LLD.REFERENCE5,
					LLD.OBJECT_VERSION_NUMBER,
					LLD.CREATED_BY_MODULE,
					LLD.SOURCE_ID,
					LLD.SOURCE_TABLE,
					ar_Activity_details_s.nextval,
					'R'
				FROM ar_Activity_details LLD
				where LLD.cash_receipt_id = p_cr_id
				and nvl(LLD.CURRENT_ACTIVITY_FLAG, 'Y') = 'Y';

			   UPDATE ar_Activity_details dtl
			     set CURRENT_ACTIVITY_FLAG = 'N'
				where dtl.cash_receipt_id = p_cr_id
				and nvl(dtl.CURRENT_ACTIVITY_FLAG, 'Y') = 'Y';

END IF;



    --}
        arp_cr_history_pkg.fetch_f_crid( p_cr_id, l_crh_rec_old );
        --
	l_crh_rec := l_crh_rec_old;
        --
        -- Insert new receipt history record and get back the
        -- new cash_receipt_history_id into l_crh_id_new
        --
	insert_reversal_crh_record( l_crh_rec,
			   p_reversal_gl_date, p_reversal_date,
			   p_clear_batch_id, p_crh_id ); /* Bug fix 3079331*/

        /*p_crh_id := l_crh_rec.cash_receipt_history_id;*/
        --
        -- Update old cash receipt history record to set all reversal columns.
        --
	update_current_crh_record( l_crh_rec_old, p_reversal_gl_date,
				  p_reversal_date, l_crh_rec.cash_receipt_history_id );
    --

    -- Insert opposing Journal Entries into ar_distributions to
    -- back out NOCOPY all existing entries belong to this cash receipt
    --
	insert_reversal_dist_rec( p_cr_id,l_crh_rec.cash_receipt_history_id );
    --

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('validate_args: ' ||  'cr_rec.type = '||l_cr_rec.type );
    END IF;
    -- if receipt_type is 'MISC', fetch the distribution record and
    -- for each fetched record, insert its opposite record.
    IF ( l_cr_rec.type = 'MISC' ) THEN
 	 OPEN ar_mcd_C( p_cr_id );
 	 LOOP
	      FETCH ar_mcd_C INTO l_mcd_rec;
	      EXIT WHEN ar_mcd_C%NOTFOUND;
	      --
              insert_reversal_mcd_record( l_mcd_rec, p_reversal_gl_date,
				 p_reversal_date );
	      --
	 END LOOP;
	 CLOSE ar_mcd_C;

/* CCRR--Check to see if this 'MISC' receipt is a negative Credit_Card receipt  pkt */

             /*Find out NOCOPY if the receipt method for this 'MISC' receipt is of CREDIT_CARD */
              v_credit_card := FALSE;
              OPEN ar_rm_C(l_cr_rec.receipt_method_id);
                FETCH ar_rm_C INTO l_rm_code;
                if l_rm_code = 'CREDIT_CARD' then
                   v_credit_card := TRUE;
                end if;
                CLOSE ar_rm_C;

            /* if the 'MISC' receipt is negative and the receipt method is Credit_card
                   then unapply the CCR on the Cash Receipt associated with this Misc receipt- pkt*/

            IF (l_cr_rec.amount < 0 and v_credit_card and
		  nvl(p_called_from,'NONE') not in ('UNAPPLY_CCR')) then
                  /* this is a negative Misc Receipt*/
                           /* Get the application receipt id that is associated with this negative Misc receipt pkt */
                               OPEN ar_rc_rec(p_cr_id);
                                FETCH ar_rc_rec INTO l_receivable_application_id;
                               CLOSE ar_rc_rec;

                            /*call the receipt api to unapply the ccr on the cash receipt pkt*/
                             declare
                                 l_return_status		varchar2(1);
   		    l_msg_count		number;
		    l_msg_data		varchar2(2000);
		    l_msg_index		number;


	BEGIN
        --call the entity handler
          arp_process_application.reverse(
                                l_receivable_application_id,
                                p_reversal_gl_date,
                                trunc(sysdate),
                                'ARREREVB_MISC',
                                NULL,
                                ln_bal_due_remaining,
                                 'REVERSE_MISC');
       EXCEPTION
         WHEN OTHERS THEN
	      IF ar_rc_rec%ISOPEN THEN
   	         CLOSE ar_rc_rec;
	      END IF;
	      --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('validate_args: ' ||  'EXCEPTION: arp_reverse_receipt.reverse' );
              END IF;
                       RAISE;
       END;
	end if;  --(l_cr_rec.amount < 0 and v_credit_card)
   ELSIF ( l_cr_rec.type = 'CASH' ) THEN
	--
        -- If receipt_type is 'CASH', fetch each receivable_application_id from
        -- ar_receivable_applications for the cash_receipt
        -- For each record fetched, reverse application
        -- Update ar_payment_schedule record with amount_due_remaining = 0,
        -- acctd_amount_due_remaining = 0, amount_applied = 0,
        -- actual_date_closed,last_update_date, last_updated_by, gl_date_closed,
        -- status = 'CL'
        -- Update ar_cash_receipts, set status to reversal_category,
        -- last_update_date = sysdate, last_updated_by = user_id,
        -- reversal_comments and attributes.
        --

        FOR l_ra_rec IN ar_ra_C( p_cr_id )
        LOOP
            --
            -- The flag 'Y' is to denote that the procedure
            -- ar_process_cash_application.reverse is called by another
            -- procedure and the GL_DATE validation need not be done again.
            -- If the flag is not 'Y', this implies the procedure is called
            -- by a form, and GL_DATE validation needs to be done and 'UNAPP'
            -- record needs to be inserted by calling
            -- ar_receivable_applications_pkg.insert
            --

            -- bug 584303:  added ln_bal_due_remaining..  Don't need to
            -- do anything with this.. it is just a place holder.

            -- Bug 2751910 - call receipt api to reverse netting applications
            -- Bug 3829332 - reversal gl_date passed in to ensure same date
	    -- used as corresponding UNAPP application.
            IF l_ra_rec.receivables_trx_id = -16 THEN
               ar_receipt_api_pub.unapply_open_receipt(
                    p_api_version               =>  1.0
                  , p_init_msg_list             =>  NULL
                  , p_commit                    =>  NULL
                  , p_validation_level          =>  NULL
                  , x_return_status             =>  l_return_status
                  , x_msg_count                 =>  l_msg_count
                  , x_msg_data                  =>  l_msg_data
                  , p_receivable_application_id =>  l_ra_rec.receivable_application_id
		  , p_reversal_gl_date		=>  p_reversal_gl_date
                  , p_called_from               =>  'ARREREVB' -- bug 2855180
                 );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                 RAISE unapply_netting_err;
               END IF;

            ELSE
               IF l_ra_rec.applied_payment_schedule_id = -8 THEN
		  ar_refunds_pvt.cancel_refund(
	 		  p_application_ref_id => l_ra_rec.application_ref_id
			, p_gl_date => p_reversal_gl_date
			, x_return_status => l_return_status
			, x_msg_count => l_msg_count
			, x_msg_data => l_msg_data);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                    RAISE cancel_refund_err;
                  END IF;
               END IF;

               arp_process_application.reverse(
                     l_ra_rec.receivable_application_id,
                     p_reversal_gl_date, p_reversal_date, 'ARREREVB', NULL,
                     ln_bal_due_remaining,p_called_from  ); /* jrautiai BR implementation */
            END IF;
        END LOOP;
        --
        -- Update the payment schedule record of the payment, set
        -- amount_dur_remaining = 0, amount_applied = 0 and status = 'CL
        -- actual_date_closed, last_update_date, last_updated_by,
        -- gl_date_closed, status = 'CL'
        --
	modify_update_ps_rec( p_cr_id, p_reversal_gl_date,
			      p_reversal_date);

   END IF;
   --
   --
   update_current_cr_rec( l_cr_rec, p_reversal_category,
                         p_reversal_date, p_reversal_reason_code,
                         p_reversal_comments,
                         p_attribute_category, p_attribute1,
                         p_attribute2, p_attribute3, p_attribute4,
                         p_attribute5, p_attribute6, p_attribute7,
                         p_attribute8, p_attribute9, p_attribute10,
                         p_attribute11, p_attribute12, p_attribute13,
                         p_attribute14, p_attribute15 );
   --
   --
   arp_cr_util.get_batch_id( p_cr_id, l_batch_id );
   IF ( l_batch_id is NOT NULL )
   THEN
      modify_update_bat_rec( l_batch_id, l_cr_rec.amount, p_reversal_category );
   END IF;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('validate_args: ' ||  'arp_reverse_receipt.reverse() -');
   END IF;
   --
    EXCEPTION
         WHEN unapply_netting_err THEN
	      IF ar_ra_C%ISOPEN THEN
   	         CLOSE ar_ra_C;
	      END IF;
	      --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('validate_args: ' ||  'EXCEPTION: arp_reverse_receipt.reverse - error calling ar_receipt_api_pub.unapply_open_receipt' );
              END IF;
              RAISE;
         WHEN cancel_refund_err THEN
	      IF ar_ra_C%ISOPEN THEN
   	         CLOSE ar_ra_C;
	      END IF;
	      --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('EXCEPTION: arp_reverse_receipt.reverse - error calling ar_refunds_pvt.cancel_refund' );
              END IF;
              RAISE;
         WHEN OTHERS THEN
	      IF ar_mcd_C%ISOPEN THEN
   	         CLOSE ar_mcd_C;
	      END IF;
	      --
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('validate_args: ' ||  'EXCEPTION: arp_reverse_receipt.reverse' );
              END IF;
              RAISE;
              --
END reverse;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to reverse procedure                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cahs receipt ID                              |
 |                    p_reversal_category - Reversal Category                |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_reversal_reason_code - Reason for reversal           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args( p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
                         p_reversal_category     IN VARCHAR2,
                         p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
                         p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
                         p_reversal_reason_code  IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.validate_args() +');
    END IF;
    --
    IF ( p_cr_id is NULL OR p_reversal_category is NULL OR
         p_reversal_gl_date is NULL OR p_reversal_date is NULL OR
         p_reversal_reason_code is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    -- Validate gl date. If it is invalid, print an error message
    --
    IF ( arp_util.is_gl_date_valid( p_reversal_gl_date ) = FALSE ) THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('validate_args: ' ||  'invalid gl date' );
          END IF;
          FND_MESSAGE.set_name ('AR', 'AR_INF_GL_DATE' );
          APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.validate_args() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
 	      IF PG_DEBUG in ('Y', 'C') THEN
 	         arp_standard.debug('validate_args: ' ||
			'EXCEPTION: arp_reverse_receipt.validate_args' );
 	      END IF;
              RAISE;
--
END validate_args;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_reversal_dist_rec                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prepare the ar_distributions record for insertion into AR_DISTRIBUTIONs|
 |    table 								     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_distributions_pkg.insert_p - Insert table handler for             |
 |                                      AR_DISTRIBUTIONS table               |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_crh_id - Cash receipt history id                     |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 04-JAN-99      D. Jancis       Modified for VAT changes for 11.5, added   |
 |                                currency_code, currency_conversion_rate,   |
 |                                currency_conversion_type,                  |
 |                                currency_conversion_date, third_party_id,  |
 |                                third_pary_sub_id.                         |
 |                                                                           |
 | 27-Jun-02      D.Jancis        Modified for mrc trigger replacement.      |
 |                                added call to ar_mrc_engine2 for processing|
 |                                ar_distributions inserts.                  |
 +===========================================================================*/
PROCEDURE insert_reversal_dist_rec(
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_crh_id IN ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
--
l_dist_rec      ar_distributions%ROWTYPE;
l_cr_rec        ar_cash_receipts%ROWTYPE;   /* added for VAT */
l_crh_rec       ar_cash_receipt_history%ROWTYPE;   /* added for VAT */
--
CURSOR ar_dist_C(
        p_cr_id ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
       SELECT
	      dist.source_type,
	      dist.code_combination_id,
	      nvl(SUM( nvl(dist.AMOUNT_DR,0)),0) -
	          nvl(SUM( nvl(dist.AMOUNT_CR,0) ),0) amount_cr,
	      nvl(SUM( nvl(dist.ACCTD_AMOUNT_DR,0) ),0) -
	          nvl(SUM( nvl(dist.ACCTD_AMOUNT_CR,0) ),0) acctd_amount_cr
       FROM ar_distributions dist,
	    ar_cash_receipt_history crh
       WHERE dist.source_id = crh.cash_receipt_history_id
	AND  crh.cash_receipt_id = p_cr_id
	ANd  dist.source_table = 'CRH'
       GROUP BY dist.source_type,
		dist.code_combination_id;

--Bug#2750340
  l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.insert_reversal_dist_rec() +');
       arp_standard.debug('insert_reversal_dist_rec: ' ||  '-- cr_id = '||to_char( p_cr_id ) );
       arp_standard.debug('insert_reversal_dist_rec: ' ||  '-- crh_id = '||to_char( p_crh_id ) );
      arp_standard.debug('insert_reversal_dist_rec: ' || '--  Fetching the cash receipt record -- ');
   END IF;
   -- Fetch the cash receipt record
   l_cr_rec.cash_receipt_id := p_cr_id;
   arp_cash_receipts_pkg.fetch_p( l_cr_rec );

   -- Fetch the history record
   arp_cr_history_pkg.fetch_p( p_crh_id, l_crh_rec );

   --  11.5 VAT changes:
   l_dist_rec.currency_code            := l_cr_rec.currency_code;
   l_dist_rec.currency_conversion_rate := l_crh_rec.exchange_rate;
   l_dist_rec.currency_conversion_type := l_crh_rec.exchange_rate_type;
   l_dist_rec.currency_conversion_date := l_crh_rec.exchange_date;
   l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
   l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;


    --
    FOR l_dist_cursor_rec IN ar_dist_C( p_cr_id )
    LOOP
       l_dist_rec.source_type := l_dist_cursor_rec.source_type;
       l_dist_rec.source_table := 'CRH';
       l_dist_rec.source_id := p_crh_id;
       l_dist_rec.code_combination_id := l_dist_cursor_rec.code_combination_id;

      IF (  l_dist_cursor_rec.amount_cr < 0 )
      THEN
         l_dist_rec.amount_dr := -l_dist_cursor_rec.amount_cr;
         l_dist_rec.amount_cr := NULL;
      ELSE
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.amount_cr := l_dist_cursor_rec.amount_cr;
      END IF;

      IF (  l_dist_cursor_rec.acctd_amount_cr < 0 )
      THEN
         l_dist_rec.acctd_amount_dr := -l_dist_cursor_rec.acctd_amount_cr;
         l_dist_rec.acctd_amount_cr := NULL;
      ELSE
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := l_dist_cursor_rec.acctd_amount_cr;
      END IF;

       --
       arp_distributions_pkg.insert_p( l_dist_rec, l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

    END LOOP;
     --

    --Bug#2750340
    l_xla_ev_rec.xla_from_doc_id := p_cr_id;
    l_xla_ev_rec.xla_to_doc_id   := p_cr_id;
    l_xla_ev_rec.xla_doc_table   := 'CRH';
    l_xla_ev_rec.xla_mode        := 'O';
    l_xla_ev_rec.xla_call        := 'B';
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.insert_reversal_dist_rec() -');
    END IF;
    EXCEPTION
    --
         WHEN OTHERS THEN
	      IF PG_DEBUG in ('Y', 'C') THEN
	         arp_standard.debug('insert_reversal_dist_rec: ' ||
		    'EXCEPTION: arp_reverse_receipt.insert_reversal_dist_rec' );
	      END IF;
              RAISE;
--
END insert_reversal_dist_rec;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_reversal_crh_record                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prepare for insertion of Insert the reversal cash receipt history recor|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |         arp_cr_history_pkg.insert_p -Insertion table handler for          |
 |                                      AR_CASH_RECEIPTS_HISTORY table       |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_crh_rec - Cash receipt history record structure      |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_clear_batch_id - Flag to denote if the batch Id      |
 |                                       should be nulled out NOCOPY or not         |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                    p_crh_id - Id of inserted ar_cash_receipt_history row  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                        05/02/95 - Removed comments around 		     |
 |				     p_crh_rec.created_from variable	     |
 |                                 - Assigned 'ARP_PROCESS_RECIPTS.REVERSE'
 |				     created_from variables               |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_reversal_crh_record(
        p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE,
        p_reversal_gl_date IN ar_misc_cash_distributions.gl_date%TYPE,
        p_reversal_date IN ar_misc_cash_distributions.apply_date%TYPE,
 	p_clear_batch_id IN VARCHAR2,
        p_crh_id OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE
       ) IS
--Bug#2750340
  l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.insert_reversal_crh_record() +');
    END IF;
    --
    -- The amount columns are not updated to 0. This was done in Rel 10.5
    -- For more info on this look at /appldev/ar/7.1/upgrade/sql/ar760u15.sql
    -- file
    --
    /***
    -- p_crh_rec.amount := 0;
    -- p_crh_rec.acctd_amount := 0;
    -- p_crh_rec.factor_discount_amount := 0;
    -- p_crh_rec.acctd_factor_discount_amount := 0;
    ***/
    --

    -- This is a new design for 10.6, the factor_flag value should
    -- stay the same as the prior history record.
    /***
    -- p_crh_rec.factor_flag := 'N';
    ***/

    p_crh_rec.first_posted_record_flag := 'N';
    p_crh_rec.current_record_flag := 'Y';
    p_crh_rec.gl_date := p_reversal_gl_date;

    IF ( p_crh_rec.status = 'APPROVED' )
    THEN
       p_crh_rec.postable_flag := 'N';
    ELSE
       p_crh_rec.postable_flag := 'Y';
    END IF;

    p_crh_rec.trx_date := p_reversal_date;
    --
    IF ( p_clear_batch_id IS NOT NULL ) THEN
         p_crh_rec.batch_id := p_clear_batch_id;
    ELSE
         IF ( p_crh_rec.status <> 'CLEARED' ) THEN
              p_crh_rec.batch_id := NULL;
         END IF;
    END IF;
    --
    p_crh_rec.status := 'REVERSED';
    p_crh_rec.gl_posted_date := NULL;
    p_crh_rec.posting_control_id := -3;
    --
    p_crh_rec.created_from := 'ARP_REVERSE_RECEIPT.REVERSE';
    --
    p_crh_rec.prv_stat_cash_receipt_hist_id :=
			p_crh_rec.cash_receipt_history_id;
    --
    -- For each row selected Insert a new cash receipt history record with
    -- status 'REVERSED'.
    --
    arp_cr_history_pkg.insert_p( p_crh_rec, p_crh_rec.cash_receipt_history_id );
    p_crh_id := p_crh_rec.cash_receipt_history_id;
    --
    --Bug#2750340
    l_xla_ev_rec.xla_from_doc_id := p_crh_rec.cash_receipt_id;
    l_xla_ev_rec.xla_to_doc_id   := p_crh_rec.cash_receipt_id;
    l_xla_ev_rec.xla_doc_table   := 'CRH';
    l_xla_ev_rec.xla_mode        := 'O';
    l_xla_ev_rec.xla_call        := 'B';
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.insert_reversal_crh_record() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('insert_reversal_crh_record: ' ||
		  'EXCEPTION: arp_reverse_receipt.insert_reversal_crh_record' );
              END IF;
              RAISE;
END insert_reversal_crh_record;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_current_crh_record                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Update the current Cash receipt history record                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_cr_history_pkg.update_p - cash receipt history update table      |
 |                                    handler                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_crh_rec -  cash receipt history record structure     |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_crh_id_new - Id of newly inserted cash receipt       |
 |                                   history row                             |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_current_crh_record(
        p_crh_rec IN OUT NOCOPY ar_cash_receipt_history%ROWTYPE,
        p_reversal_gl_date IN ar_misc_cash_distributions.gl_date%TYPE,
        p_reversal_date IN ar_misc_cash_distributions.apply_date%TYPE,
    p_crh_id_new IN ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS

  --Bug#2750340
  l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.update_current_crh_record() +');
       arp_standard.debug('update_current_crh_record: ' ||  'crh_id_new = '||to_char( p_crh_id_new ) );
    END IF;

    p_crh_rec.current_record_flag := NULL;
    p_crh_rec.reversal_gl_date := p_reversal_gl_date;
    p_crh_rec.reversal_posting_control_id := -3;
    p_crh_rec.reversal_cash_receipt_hist_id :=
					p_crh_id_new;
    p_crh_rec.reversal_created_from := 'ARP_REVERSE_RECEIPT.REVERSE';
    --
    -- For each row selected Insert a new cash receipt history record with
    -- status 'REVERSED'.
    --
    arp_cr_history_pkg.update_p( p_crh_rec );
    --
    --Bug#2750340
    l_xla_ev_rec.xla_from_doc_id := p_crh_rec.cash_receipt_id;
    l_xla_ev_rec.xla_to_doc_id   := p_crh_rec.cash_receipt_id;
    l_xla_ev_rec.xla_doc_table   := 'CRH';
    l_xla_ev_rec.xla_mode        := 'O';
    l_xla_ev_rec.xla_call        := 'B';
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.update_current_crh_record() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('update_current_crh_record: ' ||
		   'EXCEPTION: arp_reverse_receipt.update_current_crh_record' );
              END IF;
              RAISE;
--
END update_current_crh_record;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_reversal_mcd_record                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prepare for insertion of Insert the reversal misc cash distribution rec|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |         arp_misc_cash_dist_pkg.insert_p - Insertion table handler for     |
 |                                           AR_MISC_CASH_DISTRIBUTIONS table|
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_mcd_rec - Misc cash distributions receord structure  |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                        05/02/95 - Removed comments around 		     |
 |				     p_mcd_rec.created_from variable	     |
 |                                 - Assigned 'ARP_PROCESS_RECIPTS.REVERSE'
 |				     created_from variables               |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_reversal_mcd_record(
	p_mcd_rec IN OUT NOCOPY ar_misc_cash_distributions%ROWTYPE,
	p_reversal_gl_date IN ar_misc_cash_distributions.gl_date%TYPE,
	p_reversal_date IN ar_misc_cash_distributions.apply_date%TYPE ) IS
l_mcd_id	ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;
l_ae_doc_rec    ae_doc_rec_type;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.insert_reversal_mcd_record() +');
    END IF;
    --
    p_mcd_rec.gl_date := p_reversal_gl_date;
    p_mcd_rec.apply_date := p_reversal_date;
    p_mcd_rec.amount := -p_mcd_rec.amount;
    p_mcd_rec.acctd_amount := -p_mcd_rec.acctd_amount;
    p_mcd_rec.posting_control_id := -3;
    p_mcd_rec.created_from := 'ARP_REVERSE_RECEIPT.REVERSE';
    P_mcd_rec.gl_posted_date := NULL;
    --
    -- For insertion use cash_receipt_id and reversal_gl_date=NULL
    --
    arp_misc_cash_dist_pkg.insert_p( p_mcd_rec, l_mcd_id );

   --
   --Release 11.5 VAT changes, reverse accounting associated with old MCD
   --and create new distributions with new MCD id
   --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_mcd_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'MCD';
    l_ae_doc_rec.source_id                 := l_mcd_id;
    l_ae_doc_rec.source_id_old             := p_mcd_rec.misc_cash_distribution_id;
    l_ae_doc_rec.other_flag                := 'REVERSE';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.insert_reversal_mcd_record() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('insert_reversal_mcd_record: ' ||
		  'EXCEPTION: arp_reverse_receipt.insert_reversal_mcd_record' );
              END IF;
              RAISE;
--
END insert_reversal_mcd_record;
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_cb                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Check if there is any activity associated with a charge back of a      |
 |    cash receipt                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt id                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : TRUE / FALSE                                                 |
 |                                                                           |
 | NOTES - This could be converted to a PUBLIC function later                |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                        05/03/95-  Fixed a bug in check_cb function        |
 |				     The last line in the SQL statement      |
 |				     should have been adj.receivables_trx_id |
 |				     <> arp_global.... instead of = arp_gl...|
 |                                                                           |
 +===========================================================================*/
FUNCTION check_cb( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE )
		   RETURN BOOLEAN IS
l_count			NUMBER DEFAULT 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.check_cb() +');
       arp_standard.debug('check_cb: ' ||  'cr_id = '||to_char( p_cr_id ) );
    END IF;
    --
    SELECT COUNT(*)
    INTO   l_count
    FROM   ar_payment_schedules ps,
           ra_cust_trx_line_gl_dist ctlg
    WHERE  ps.associated_cash_receipt_id = p_cr_id
    AND    ps.class = 'CB'
    AND    ps.customer_trx_id = ctlg.customer_trx_id
    AND    ( NVL( ps.amount_applied, 0 ) <> 0
	     OR NVL(  ps.amount_credited, 0 ) <> 0
	     OR 0 <> ( SELECT sum( adj.amount )
		       FROM   ar_adjustments adj
	 	       WHERE  adj.payment_schedule_id = ps.payment_schedule_id
		       AND    adj.receivables_trx_id <>
					arp_global.G_CB_REV_RT_ID
		     )
           );
    IF ( l_count > 0 ) THEN
         RETURN FALSE;
    ELSE
         RETURN TRUE;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.check_cb() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: arp_reverse_receipt.check_cb' );
              END IF;
              RAISE;
END check_cb;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    modify_update_ps_rec                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prepare for updation into payment schedule record                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |          arp_ps_util.get_closed_dates - Get closed dates                     |
 |          arp_ps_pkg.fetch_f_cr_id - Fetch from payment    |
 |                      Schedule table handler useing cash receipt id        |
 |          arp_ps_pkg.update_p - update payment schedule row |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt id                              |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE modify_update_ps_rec(
		p_cr_id IN ar_payment_schedules.cash_receipt_id%TYPE,
		p_reversal_gl_date IN DATE,
                p_reversal_date IN DATE ) IS
l_gl_date_closed 	DATE;
l_actual_date_closed	DATE;
l_ps_rec        	ar_payment_schedules%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.modify_update_ps_rec() +' );
       arp_standard.debug('modify_update_ps_rec: ' ||  to_char( p_cr_id ) );
       arp_standard.debug('modify_update_ps_rec: ' ||  'cr_id = '||to_char( p_cr_id ) );
    END IF;
    --
    arp_ps_pkg.fetch_fk_cr_id( p_cr_id, l_ps_rec );
    arp_ps_util.get_closed_dates( l_ps_rec.payment_schedule_id,
                         p_reversal_gl_date,
                         p_reversal_date,
                         l_gl_date_closed,
                         l_actual_date_closed, 'PMT' );
    --
    l_ps_rec.amount_due_remaining := 0;
    l_ps_rec.acctd_amount_due_remaining := 0;
    l_ps_rec.amount_applied := 0;
    l_ps_rec.actual_date_closed := l_actual_date_closed;
    l_ps_rec.gl_date_closed := l_gl_date_closed;
    l_ps_rec.status := 'CL';
    --
    arp_ps_pkg.update_p( l_ps_rec );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.modify_update_ps_rec() +' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('modify_update_ps_rec: ' ||
			'EXCEPTION: arp_reverse_receipt.modify_update_ps_rec' );
              END IF;
              RAISE;
--
END modify_update_ps_rec;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_current_cr_rec                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prepare for updation of current cash receipts row                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |          arp_cash_receipts_pkg.update_p - Update payment schedule handler |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_crh_rec - Cash receipt history record structure      |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_clear_batch_id - Flag to denote if the batch Id      |
 |                                       should be nulled out NOCOPY or not         |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                        05/10/95-  Nulled out NOCOPY selected_remittance_batch_id |
 |				     column                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_current_cr_rec(
            p_cr_rec             IN OUT NOCOPY ar_cash_receipts%ROWTYPE,
            p_reversal_category  IN ar_cash_receipts.reversal_category%TYPE,
            p_reversal_date      IN ar_cash_receipts.reversal_date%TYPE,
            p_reversal_reason_code IN ar_cash_receipts.reversal_reason_code%TYPE,
            p_reversal_comments  IN ar_cash_receipts.reversal_comments%TYPE,
            p_attribute_category IN ar_cash_receipts.attribute_category%TYPE,
            p_attribute1         IN ar_cash_receipts.attribute1%TYPE,
            p_attribute2         IN ar_cash_receipts.attribute2%TYPE,
            p_attribute3         IN ar_cash_receipts.attribute3%TYPE,
            p_attribute4         IN ar_cash_receipts.attribute4%TYPE,
            p_attribute5         IN ar_cash_receipts.attribute5%TYPE,
            p_attribute6         IN ar_cash_receipts.attribute6%TYPE,
            p_attribute7         IN ar_cash_receipts.attribute7%TYPE,
            p_attribute8         IN ar_cash_receipts.attribute8%TYPE,
            p_attribute9         IN ar_cash_receipts.attribute9%TYPE,
            p_attribute10        IN ar_cash_receipts.attribute10%TYPE,
            p_attribute11        IN ar_cash_receipts.attribute11%TYPE,
            p_attribute12        IN ar_cash_receipts.attribute12%TYPE,
            p_attribute13        IN ar_cash_receipts.attribute13%TYPE,
            p_attribute14        IN ar_cash_receipts.attribute14%TYPE,
            p_attribute15        IN ar_cash_receipts.attribute15%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.update_current_cr_rec() +' );
    END IF;
    --
    p_cr_rec.selected_remittance_batch_id := NULL;
    p_cr_rec.reversal_category := p_reversal_category;
    p_cr_rec.status := p_reversal_category;
    p_cr_rec.reversal_date := p_reversal_date;
    p_cr_rec.reversal_comments := p_reversal_comments;
    p_cr_rec.reversal_date := p_reversal_date;
    p_cr_rec.reversal_reason_code := p_reversal_reason_code;
    p_cr_rec.attribute_category := p_attribute_category;
    p_cr_rec.attribute1 := p_attribute1;
    p_cr_rec.attribute2 := p_attribute2;
    p_cr_rec.attribute3 := p_attribute3;
    p_cr_rec.attribute4 := p_attribute4;
    p_cr_rec.attribute5 := p_attribute5;
    p_cr_rec.attribute6 := p_attribute6;
    p_cr_rec.attribute7 := p_attribute7;
    p_cr_rec.attribute8 := p_attribute8;
    p_cr_rec.attribute9 := p_attribute9;
    p_cr_rec.attribute10 := p_attribute10;
    p_cr_rec.attribute11 := p_attribute11;
    p_cr_rec.attribute12 := p_attribute12;
    p_cr_rec.attribute13 := p_attribute13;
    p_cr_rec.attribute14 := p_attribute14;
    p_cr_rec.attribute15 := p_attribute15;
    ---
    arp_cash_receipts_pkg.update_p( p_cr_rec );
     ---
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.update_current_cr_rec() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('update_current_cr_rec: ' ||
		       'EXCEPTION: arp_reverse_receipt.update_current_cr_rec' );
              END IF;
              RAISE;
--
END update_current_cr_rec;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    modify_update_bat_rec                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prepare for updation into AR_BATCHES table                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |          arp_cr_batches_pkg.fetch_p - Fetch a row from AR_BATCHES row        |
 |          arp_cr_batches_pkg.update_p - Update a row in AR_BATCHES row        |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_bat_id - AR_BATCHES batch id                         |
 |                    p_cr_amount - Cash receipt amount                      |
 |                    p_status - Reversal category of receipt                |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 | 30-SEP-96    Shiv Ragunat    Bug 398344, Commented Out NOCOPY Updation of        |
 |                              Control_Count And Control_Amount in          |
 |                              ar_batches .                                 |
 |                              By definition - These 2 columns will no      |
 |                              longer will be updated.                      |
 +===========================================================================*/
PROCEDURE modify_update_bat_rec( p_bat_id       IN ar_batches.batch_id%TYPE,
		       		 p_cr_amount    IN ar_cash_receipts.amount%TYPE,
		       		 p_status       IN VARCHAR2 ) IS
l_bat_rec		ar_batches%ROWTYPE;
l_status		ar_batches.status%TYPE;
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.modify_update_bat_rec() +');
       arp_standard.debug('modify_update_bat_rec: ' ||  'cr_count = '||to_char( p_cr_amount ) );
       arp_standard.debug('modify_update_bat_rec: ' ||  'cr_amount = '||to_char( l_bat_rec.control_amount ) );
    END IF;
    --
    -- If there are no batches associated with the receipt, then return
    --
    BEGIN
         SELECT *
         INTO   l_bat_rec
         FROM   ar_batches
         WHERE  batch_id = p_bat_id;
         --
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
	         IF PG_DEBUG in ('Y', 'C') THEN
	            arp_standard.debug('modify_update_bat_rec: ' ||  'No Batches associated with the receipt' );
	         END IF;
                   RETURN;
             WHEN OTHERS THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('modify_update_bat_rec: ' ||
		       'EXCEPTION: arp_reverse_receipt.modify_update_bat_rec' );
                 END IF;
    END;
    --
    -- determine if the batch has any unposted quick cash receipt
    -- in the AR_INTERIM_CASH_RECEIPTS table
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('modify_update_bat_rec: ' ||  'p_status = '||p_status );
    END IF;
    --
    --
    --
    -- Shiv Ragunat - 9/30/96
    -- Commenting it out NOCOPY as part of fix for Bug 398344
    -- By Definition - Control Count and Control AMount
    -- Will no longer be updated.
    --
    --
    --
 /* IF ( p_status <> 'REV' AND p_status IS NOT NULL) THEN
         l_bat_rec.control_count := l_bat_rec.control_count - 1;
         l_bat_rec.control_amount := l_bat_rec.control_amount - p_cr_amount;
    END IF;
    --
    IF ( l_bat_rec.control_count = 0 ) THEN
         IF ( l_bat_rec.control_amount = 0 ) THEN
              IF ( p_status = 'APP' OR p_status = 'NSF' OR
		   p_status = 'STOP' ) THEN
                   l_bat_rec.status := 'CL';
              ELSE
                   l_bat_rec.status := 'OP';
	      END IF;
         ELSE
             l_bat_rec.status := 'OOB';
         END IF;
    ELSE
         l_bat_rec.status := 'OOB';
    END IF;                                                   */



    --
    arp_cr_batches_pkg.update_p( l_bat_rec );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.modify_update_bat_rec() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('modify_update_bat_rec: ' ||
		       'EXCEPTION: arp_reverse_receipt.modify_update_bat_rec' );
              END IF;
	      RAISE;

END modify_update_bat_rec;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    debit_memo_reversal                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Create a debit memo( basically an invoice for the receipt applied      |
 |    amount. This happens when a check bounces and the customer needs to    |
 |    charged for the check amount. This involves creation of a new invoice  |
 |    (debit memo) for the amount of the check( receipt ).                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_app_pkg.lock_p  - lock  a record in                               |
 |                                        AR_RECEIVABLE_APPLICATIONS table   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_reversal_reason_code - Reason for reversal           |
 |                    p_reversal_comments - Reversal comments                |
 |                    p_cust_trx_type_id - Transaction type Id               |
 |                    p_module_name - Name of module that called this proc.  |
 |                    p_module_version - Version of the module that called   |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 | 05-FEB-1996	OSTEINME	Added parameters to allow function to return |
 |				trx_number and document number data          |
 |				modified function to determine trx_number    |
 |				and document number			     |
 | 7/31/1996	Harri Kaukovuo	Fixed procedure to use document numbers      |
 |				only if profile option says so.		     |
 |				Changed the document number datatypes to be  |
 |				NUMBER instead of BINARY_INTEGER because of  |
 |				future expansion of document number range.   |
 | 12-SEP-1996  OSTEINME	modified parameters to debit_memo_reversal   |
 |				to allow for document number info to be      |
 |				passed it.				     |
 | 19-AUG-1997  OSTEINME	added two new parameters (NULL) to call to   |
 |				procedure insert_line for Rel. 11.           |
 | 21-NOV-1997  Karen Murphy    Bug 522837.                                  |
 |                              Removed TO_NUMBER( p_module_version )        |
 |                              in calls to the transactions workbench       |
 |                              as this causes problems in environments      |
 |                              using different number formatting, e.g. Spain|
 |                              and Germany.  Passing NULL instead as this   |
 |                              functionality has not been implemented.      |
 | 09-FEB-1999  Debbie Jancis   Modified for 11.5 BOE changes to pass the    |
 |                              trx_number if the dm_inherit_receipt_num_flag|
 |                              is set                                       |
 | 17-FEB-1999  Ramakant Alat   Updating the TRX_NUMBER with Document Number |
 |                              if the COPY option is set at Bacth Source    |
 | 08-SEP-1999  J Rautiainen    BugFix for bug 976703. Cursor customer_C was |
 |                              split into two separate cursors for          |
 |                              performance reasons                          |
 | 29-MAR-2000  V Crisostomo    Bug 753554 : Modify method of selecting crh  |
 |                              to get ccids from                            |
 | 12-APR-2000  Skoukunt        Bug 1063133 : Added 2nd i/p parameter for the|
 |                              cursor bill_to_customer_C                    |
 +===========================================================================*/

PROCEDURE debit_memo_reversal(
        p_cr_rec            IN OUT NOCOPY ar_cash_receipts%ROWTYPE,
        p_cc_id            IN ra_cust_trx_line_gl_dist.code_combination_id%TYPE,
        p_cust_trx_type_id IN ra_cust_trx_types.cust_trx_type_id%TYPE,
	p_cust_trx_type	   IN ra_cust_trx_types.name%TYPE,
        p_reversal_gl_date IN ar_cash_receipt_history.reversal_gl_date%TYPE,
        p_reversal_date    IN ar_cash_receipts.reversal_date%TYPE,
	p_reversal_category IN ar_cash_receipts.reversal_category%TYPE,
        p_reversal_reason_code  IN
                              ar_cash_receipts.reversal_reason_code%TYPE,
	p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
	p_attribute_category	IN ar_cash_receipts.attribute_category%TYPE,
	p_attribute1    	IN ar_cash_receipts.attribute1%TYPE,
	p_attribute2    	IN ar_cash_receipts.attribute2%TYPE,
	p_attribute3    	IN ar_cash_receipts.attribute3%TYPE,
	p_attribute4    	IN ar_cash_receipts.attribute4%TYPE,
	p_attribute5    	IN ar_cash_receipts.attribute5%TYPE,
	p_attribute6    	IN ar_cash_receipts.attribute6%TYPE,
	p_attribute7    	IN ar_cash_receipts.attribute7%TYPE,
	p_attribute8    	IN ar_cash_receipts.attribute8%TYPE,
	p_attribute9    	IN ar_cash_receipts.attribute9%TYPE,
	p_attribute10   	IN ar_cash_receipts.attribute10%TYPE,
	p_attribute11   	IN ar_cash_receipts.attribute11%TYPE,
	p_attribute12   	IN ar_cash_receipts.attribute12%TYPE,
	p_attribute13   	IN ar_cash_receipts.attribute13%TYPE,
	p_attribute14   	IN ar_cash_receipts.attribute14%TYPE,
	p_attribute15   	IN ar_cash_receipts.attribute15%TYPE,
	p_dm_number		OUT NOCOPY ar_payment_schedules.trx_number%TYPE,
	p_dm_doc_sequence_value IN ra_customer_trx.doc_sequence_value%TYPE,
	p_dm_doc_sequence_id	IN ra_customer_trx.doc_sequence_id%TYPE,
        p_status		IN OUT NOCOPY VARCHAR2,
        p_module_name      IN VARCHAR2,
        p_module_version   IN VARCHAR2 ) IS

l_receipt_method_name  ar_receipt_methods.name%TYPE;
l_receipt_number      ar_cash_receipts.receipt_number%TYPE;
l_customer_id         ar_cash_receipts.pay_from_customer%TYPE;

l_currency_code       ar_cash_receipts.currency_code%TYPE;
l_exchange_rate_type  ar_cash_receipts.exchange_rate_type%TYPE;
l_exchange_rate       ar_cash_receipts.exchange_rate%TYPE;
l_exchange_date       ar_cash_receipts.exchange_date%TYPE;

l_amount              ar_cash_receipts.amount%TYPE;

l_description         ra_customer_trx_lines.description%TYPE;

l_rev1_cc_id          ar_cash_receipt_history.account_code_combination_id%TYPE;
l_rev1_amount         ar_cash_receipt_history.amount%TYPE;
l_rev2_cc_id          ar_cash_receipt_history.bank_charge_account_ccid%TYPE;
l_rev2_amount         ar_cash_receipt_history.factor_discount_amount%TYPE;

l_ct_rec              ra_customer_trx%ROWTYPE;
l_ct_lines_rec        ra_customer_trx_lines%ROWTYPE;
l_comm_rec            arp_process_commitment.commitment_rec_type;

l_trx_number              ra_customer_trx.trx_number%TYPE;
l_customer_trx_id         ra_customer_trx.customer_trx_id%TYPE;
l_customer_trx_line_id    ra_customer_trx_lines.customer_trx_line_id%TYPE;

l_count                  NUMBER := 0;

l_rule_start_date          ra_customer_trx_lines.rule_start_date%type;
l_accounting_rule_duration ra_customer_trx_lines.accounting_rule_duration%type;
l_gl_date_dummy            ra_cust_trx_line_gl_dist.gl_date%type;
l_trx_date_dummy           ra_customer_trx.trx_date%type;
l_status_dummy             varchar2(100);

l_commit_cust_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%type;
l_rowid                    rowid;

l_dm_number		   ar_payment_schedules.trx_number%TYPE;
--l_sequence_name		   VARCHAR2(500);
--l_sequence_id		   NUMBER;
--l_sequence_assignment_id   NUMBER;
--l_sequence_value	   NUMBER;
l_cr_id			   NUMBER;
l_crhid			   NUMBER;

l_term_end_date            DATE; /*5084781*/

/* for 11.5 BOE Changes */
/*l_rcpt_inherit_inv_num_flag VARCHAR2(1);  Bug 3246178*/
l_dm_inherit_rcpt_num_flag  VARCHAR2(1);
l_does_it_exist             VARCHAR2(1);

/* Document Sequencing Project Changes */
l_copy_doc_number_flag     RA_BATCH_SOURCES.copy_doc_number_flag%TYPE;

/*Legal Entity for DM reversal 5126184*/
l_legal_entity_id   ra_customer_trx.legal_entity_id%TYPE;

/* 08-SEP-1999 J Rautiainen BugFix for bug 976703
 * Cursor customer_C was split into two separate cursors for performance
 * reasons */
-- Added 2nd i/p parameter to fix bug 1063133
CURSOR  bill_to_customer_C( l_customer_id hz_cust_accounts.cust_account_id%TYPE,
               l_site_use_id ar_cash_receipts.customer_site_use_id%TYPE ) IS
    SELECT su1.site_use_id site_use_id,
           su1.cust_acct_site_id address_id
    FROM   hz_cust_site_uses       su1,
           hz_cust_acct_sites      add1
    WHERE  add1.cust_account_id = l_customer_id
    AND    add1.cust_acct_site_id      = su1.cust_acct_site_id
    /* 02-JUN-2000 J Rautiainen BR Implementation
     * The site can also be DRAWEE */
    AND     su1.site_use_code    in ('BILL_TO','DRAWEE')
    AND    su1.site_use_id = nvl(l_site_use_id,su1.site_use_id)
    ORDER BY su1.primary_flag desc;

CURSOR  ship_to_customer_C( l_customer_id hz_cust_accounts.cust_account_id%TYPE ) IS
    SELECT DECODE( su2.site_use_id,
                   NULL, NULL, add2.cust_account_id ) ship_to_customer_id,
           su2.site_use_id ship_to_site_use_id
    FROM   hz_cust_site_uses       su2,
           hz_cust_acct_sites      add2
    WHERE  add2.cust_account_id = l_customer_id
    AND    add2.cust_acct_site_id  = su2.cust_acct_site_id
    AND    su2.site_use_code = 'SHIP_TO'
    ORDER BY su2.primary_flag desc;

BEGIN
    --
    -- arp_standard.enable_debug;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.debit_memo_reversal() +');
       arp_standard.debug('debit_memo_reversal: ' || 'Parameters:');
       arp_standard.debug('debit_memo_reversal: ' || 'p_cr_id			= ' || p_cr_rec.cash_receipt_id);
       arp_standard.debug('debit_memo_reversal: ' || 'p_cc_id			= ' || p_cc_id);
       arp_standard.debug('debit_memo_reversal: ' || 'p_cust_trx_type_id	= ' || p_cust_trx_type_id);
       arp_standard.debug('debit_memo_reversal: ' || 'p_cust_trx_type		= ' || p_cust_trx_type);
       arp_standard.debug('debit_memo_reversal: ' || 'p_reversal_gl_date	= ' || TO_CHAR(p_reversal_gl_date));
       arp_standard.debug('debit_memo_reversal: ' || 'p_reversal_date		= ' || TO_CHAR(p_reversal_date));
       arp_standard.debug('debit_memo_reversal: ' || 'p_reversal_reason_code  = ' || p_reversal_reason_code);
       arp_standard.debug('debit_memo_reversal: ' || 'p_module_name		= ' || p_module_name);
       arp_standard.debug('debit_memo_reversal: ' || 'p_module_version	= ' || p_module_version);
    END IF;

    l_cr_id := p_cr_rec.cash_receipt_id;

    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
         validate_dm_reversal_args( l_cr_id, p_cc_id,
                                    p_cust_trx_type_id, p_reversal_gl_date,
                                    p_reversal_date, p_reversal_reason_code );
    END IF;
    --
    -- Validate gl date. If it is invalid, print an error message
    --
    IF ( arp_util.is_gl_date_valid( p_reversal_gl_date ) = FALSE ) THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('debit_memo_reversal: ' ||  'invalid gl date' );
          END IF;
          FND_MESSAGE.set_name ('AR', 'AR_INF_GL_DATE' );
          APP_EXCEPTION.raise_exception;
    END IF;
    --
    -- Get receipt method name, currency code, exchange rate info and
    -- receipt amount
    --
    --  BOE changes:  get the dm_inherit_receipt_num_flag to deterime
    --                if we need to populate the trx_number.
    /*Bug 3246178*/

    SELECT rm.name,
           cr.pay_from_customer,
           cr.receipt_number,
           currency_code,
           exchange_rate_type,
           exchange_rate,
           exchange_date,
           amount,
           rm.dm_inherit_receipt_num_flag,
	   cr.legal_entity_id
    INTO   l_receipt_method_name,
           l_customer_id,
           l_receipt_number,
           l_currency_code,
           l_exchange_rate_type,
           l_exchange_rate,
           l_exchange_date,
           l_amount,
           l_dm_inherit_rcpt_num_flag,
	   l_legal_entity_id --5126184
    FROM
           ar_receipt_methods rm
	   , ar_cash_receipts cr
    WHERE  cr.cash_receipt_id = l_cr_id
    AND    rm.receipt_method_id = cr.receipt_method_id;
    --
    -- Get description to be used during RA_CUSTOMER_TRX_LINES insertion
    --

    /*  Bug 4684829 Changing AR_MEMO_LINES to AR_MEMO_LINES_B and AR_MEMO_LINES_TL
        We can directly use ar_memo_lines_vl too but case bug for a bug in
        ar_memo_lines_vl is dtill pending.  */

    SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(T.description,
                                                '&'||'payment_number'||'&',
                                                l_receipt_number),
                                        '&'||'PAYMENT_NUMBER'||'&',
                                        l_receipt_number),
                                '&'||'receipt_number'||'&',
                                l_receipt_number),
                        '&'||'RECEIPT_NUMBER'||'&',
                        l_receipt_number),
                '&'||'payment_method'||'&',
                l_receipt_method_name ),
        '&'||'PAYMENT_METHOD'||'&',
        l_receipt_method_name )
    INTO   l_description
    FROM  ar_memo_lines_b B ,ar_memo_lines_tl T
    WHERE B.MEMO_LINE_ID = T.MEMO_LINE_ID
    AND   NVL(B.ORG_ID, -99) = NVL(T.ORG_ID, -99)
    AND   T.LANGUAGE = userenv('LANG')
    AND   mo_global.check_access(B.ORG_ID) = 'Y'
    AND   B.memo_line_id = 2;



    --
    -- Get Revenue account ccid's and amounts
    -- Bug 753554 : instead of using current_record_flag to pick the record to
    -- get ccids from, use the highest crh_id whose status <> RISK_ELIMINATED

    SELECT max(cash_receipt_history_id)
    INTO   l_crhid
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_id = l_cr_id
    AND    status <> 'RISK_ELIMINATED';

    SELECT account_code_combination_id,
           bank_charge_account_ccid,
           amount,
           NVL(factor_discount_amount,0)
    INTO   l_rev1_cc_id,
           l_rev2_cc_id,
           l_rev1_amount,
           l_rev2_amount
    FROM ar_cash_receipt_history
    WHERE cash_receipt_id = l_cr_id
    AND   cash_receipt_history_id = l_crhid;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('debit_memo_reversal: ' || 'l_rev1_cc_id = ' || l_rev1_cc_id);
       arp_standard.debug('debit_memo_reversal: ' || 'l_rev2_cc_id = ' || l_rev2_cc_id);
       arp_standard.debug('debit_memo_reversal: ' || 'l_rev1_amount = ' || l_rev1_amount);
       arp_standard.debug('debit_memo_reversal: ' || 'l_rev2_amount = ' || l_rev2_amount);
       arp_standard.debug('debit_memo_reversal: ' || 'l_cr_id = ' || l_cr_id);
    END IF;

    --
    -- Call invoice side transaction header entity handler
    --
    l_ct_rec.cust_trx_type_id := p_cust_trx_type_id;
    l_ct_rec.invoice_currency_code := l_currency_code;
    l_ct_rec.exchange_rate_type := l_exchange_rate_type;
    l_ct_rec.exchange_date := l_exchange_date;
    l_ct_rec.exchange_rate := l_exchange_rate;
    l_ct_rec.created_from := p_module_name;
    l_ct_rec.trx_date := p_reversal_date;
    l_ct_rec.batch_source_id := 11;
    l_ct_rec.status_trx := 'OP';
    l_ct_rec.sold_to_customer_id := l_customer_id;
    l_ct_rec.bill_to_customer_id := l_customer_id;
    l_ct_rec.term_id := 5;
    l_ct_rec.complete_flag := 'Y';
    l_ct_rec.primary_salesrep_id := -3;
    l_ct_rec.reason_code := p_reversal_reason_code;
    l_ct_rec.legal_entity_id := l_legal_entity_id ; --5126184

 /*5084781 Begin*/
    select end_date_active
           into l_term_end_date
    from ra_terms where term_id = 5;

    IF (NVL(l_term_end_date, to_date('31-12-4712','DD-MM-YYYY')) < p_reversal_date) THEN
         FND_MESSAGE.SET_NAME('AR','AR_RW_PAYMENT_TERM_END_DATED');
         fnd_msg_pub.Add;
         APP_EXCEPTION.raise_exception;
    END IF;
   /*5084781 End*/

    --
    -- Get sold_to_customer_id, sold_to_site_use_id, bill_to_customer_id,
    -- bill_to_site_use_id, ship_to_customer_id, ship_to_site_use_id
    --
    /* 08-SEP-1999 J Rautiainen BugFix for bug 976703
     * Cursor customer_C was split into two separate cursors for performance
     * reasons. Here the fetching is splitted into two steps. The shipping
     * site is not mandatory, so the possible error message is not dependent of it */
    -- Added p_cr_rec.customer_site_use_id to fix bug 1063133
    FOR l_bill_to_customer_rec IN bill_to_customer_C( l_customer_id,
                                      p_cr_rec.customer_site_use_id )
    LOOP
        l_count := l_count + 1;
        --
        l_ct_rec.sold_to_site_use_id := l_bill_to_customer_rec.site_use_id;
        l_ct_rec.bill_to_site_use_id := l_bill_to_customer_rec.site_use_id;
        --
        -- Exit after fetching 1 row
        --
        EXIT;
        --
    END LOOP;
    --
    -- If not even a single row is found, then error out NOCOPY
    --
    IF ( l_count  = 0 ) THEN
        FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.set_token( 'GENERIC_MESSAGE', SQLERRM );
        APP_EXCEPTION.raise_exception;
    END IF;

    l_ct_rec.ship_to_customer_id := NULL;
    l_ct_rec.ship_to_site_use_id := NULL;
/* Fix bug 1063133
    FOR l_ship_to_customer_rec IN ship_to_customer_C( l_customer_id )
    LOOP

        l_ct_rec.ship_to_customer_id := l_ship_to_customer_rec.ship_to_customer_id;
        l_ct_rec.ship_to_site_use_id := l_ship_to_customer_rec.ship_to_site_use_id;
        --
        -- Exit after fetching 1 row
        --
        EXIT;
        --
    END LOOP;
*/

    -- If at least one row is found, then call invoice header EH and exit
    --

    -- Before we call the invoice header EH, we need to deterime if we
    -- need to populate the trx_number with the receipt_number.

 /*Bug 3246178 Removed the condition to check
 receipt_inherit_inv_num_flag to  populate the trx_number*/
    IF (l_dm_inherit_rcpt_num_flag = 'Y') THEN
        l_ct_rec.trx_number := SUBSTR(l_receipt_number,1,20);

       /* need to check if this trx_number exists (ie. there is
          DM with the same trx_number and same batch source */

       SELECT  decode ( max(dummy), NULL, 'N','Y')
          INTO l_does_it_exist
        from dual
          where exists (select trx_number from
                        ra_customer_trx, ra_cust_trx_types
                        where trx_number = l_ct_rec.trx_number
                          and batch_source_id = l_ct_rec.batch_source_id
                          and ra_customer_trx.cust_trx_type_id =
                                   ra_cust_trx_types.cust_trx_type_id
                          and ra_cust_trx_types.type = 'DM');

       /* if a DM exists with the same number and the same batch source,
          then we use existing functionality and call the EH without a
          trx_number */

       IF (l_does_it_exist = 'Y') THEN
           l_ct_rec.trx_number := '';
       END IF;
    END IF;


    -- 11/21/97 Karen Murphy
    -- Bug 522837
    -- Removed TO_NUMBER( p_module_version ) as this causes problems
    -- in envrionments using different number formatting, e.g. Spain
    -- and Germany.  Passing NULL instead as this functionality has
    -- not been implemented.
    arp_process_header.insert_header( p_module_name,
                                      NULL,   -- p_module_version
                                      l_ct_rec, 'DM_REV', p_reversal_gl_date,
                                      NULL, l_comm_rec, l_trx_number,
                                      l_customer_trx_id,
                                      l_commit_cust_trx_line_id,
                                      l_rowid,
				      p_status,
                                      p_cc_id );
    --
    -- Call invoice lines EH
    --
    l_ct_lines_rec.customer_trx_id := l_customer_trx_id;
    l_ct_lines_rec.description := l_description;
    l_ct_lines_rec.line_type := 'LINE';
    l_ct_lines_rec.line_number := 1;
    l_ct_lines_rec.quantity_ordered := 1;
    l_ct_lines_rec.quantity_invoiced := 1;
    l_ct_lines_rec.unit_selling_price := l_amount;
    l_ct_lines_rec.extended_amount := l_amount;
    l_ct_lines_rec.revenue_amount := l_amount;
    --
    -- trx_date, gl_date will be fetched from header record. Also need to pass
    -- Check which function updates PS table and the REVERSED_CASH_RECEIPT_ID
    -- column in PS table should get the l_cr_id value. Do not know which
    -- procedure arp_process_line.insert_line or
    -- arp_process_header.post_commit updates PS table
    -- in l_cr_id - dandy
    --

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Debit_Memo_Reversal: Before calling arp_p_l.insert_line');
    END IF;

    /* added two new NULL parameters to call to insert_line, due to spec
       changes in transaction package (OSTEINME, 8/19/97)		 */

    -- 11/21/97 Karen Murphy
    -- Bug 522837
    -- Removed TO_NUMBER( p_module_version ) as this causes problems
    -- in envrionments using different number formatting, e.g. Spain
    -- and Germany.  Passing NULL instead as this functionality has
    -- not been implemented.

    arp_process_line.insert_line( p_module_name,
				  NULL,   -- p_module_version
                                  l_ct_lines_rec,
				  NULL,
                                  l_customer_trx_line_id,
				  'DM_REV',
                                  l_rev1_cc_id,
				  l_rev2_cc_id,
                                  l_rev1_amount,
				  l_rev2_amount,
                                  l_rule_start_date,
                                  l_accounting_rule_duration,
				  l_gl_date_dummy,
				  l_trx_date_dummy,
				  NULL,			-- added for Rel. 11
				  NULL,			-- added for Rel. 11
                                  l_status_dummy );


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('debit_memo_reversal: ' || 'l_status_dummy after insert_line:' || l_status_dummy);
    END IF;

    -- if first call (to insert_header) was successful, then return
    -- result of insert_line, otherwise return first error message.

    IF (p_status = 'OK') THEN
      p_status := l_status_dummy;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Debit_Memo_Reversal: Before calling arp_p_h.post_commit');
    END IF;
    -- 11/21/97 Karen Murphy
    -- Bug 522837
    -- Removed TO_NUMBER( p_module_version ) as this causes problems
    -- in envrionments using different number formatting, e.g. Spain
    -- and Germany.  Passing NULL instead as this functionality has
    -- not been implemented.

    arp_process_header.post_commit( p_module_name,
                                    NULL,   -- p_module_version
                                    l_customer_trx_id,
                                    NULL, 'Y', NULL, NULL, 'A', NULL, NULL,
                                    l_cr_id );

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Debit_Memo_Reversal: After calling arp_p_h.post_commit');
    END IF;

    BEGIN
       SELECT
          NVL(copy_doc_number_flag, 'N')
       INTO
          l_copy_doc_number_flag
       FROM
          ra_batch_sources
       WHERE
          batch_source_id = l_ct_rec.batch_source_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  l_copy_doc_number_flag := 'N';
    END;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('debit_memo_reversal: ' || 'Get the Copy Doc Number Flag :' || l_copy_doc_number_flag );
    END IF;

    -- update debit memo with document number :
    -- Also copy the Document Number into Trx Number if "Copy" Flag set at Batch Source.

    /* Bug3328690 To update the reversed cash_receipt id in ra_customer_trx */
    /* Bug3347452 To Type Cast explicit p_dm_sequence_value to character
       in NVL as it raises -ORA-01722 invalid number */

    IF l_copy_doc_number_flag = 'Y' THEN
       UPDATE 	ra_customer_trx
       SET 	DOC_SEQUENCE_VALUE = p_dm_doc_sequence_value,
   		DOC_SEQUENCE_ID    = p_dm_doc_sequence_id,
		/* Bug3347452 */
   		/*TRX_NUMBER         = NVL(p_dm_doc_sequence_value, TRX_NUMBER),*/
		TRX_NUMBER	= NVL(TO_CHAR(p_dm_doc_sequence_value),TRX_NUMBER),
   		OLD_TRX_NUMBER     = DECODE(p_dm_doc_sequence_value, null,
								     OLD_TRX_NUMBER,
								     TRX_NUMBER),
		REVERSED_CASH_RECEIPT_ID=l_cr_id 	/*3328690 */
       WHERE	customer_trx_id = (
   			select customer_trx_id
                           from ar_payment_schedules
                           where class = 'DM'
                           and reversed_cash_receipt_id = l_cr_id
                                   );
       UPDATE ar_payment_schedules
	/* Bug3347452 */
        /*SET    TRX_NUMBER = NVL(p_dm_doc_sequence_value, TRX_NUMBER)*/
          SET    TRX_NUMBER = NVL(TO_CHAR(p_dm_doc_sequence_value), TRX_NUMBER)
       WHERE  reversed_cash_receipt_id = l_cr_id;

    ELSE
       UPDATE 	ra_customer_trx
       SET 	DOC_SEQUENCE_VALUE = p_dm_doc_sequence_value,
   		DOC_SEQUENCE_ID    = p_dm_doc_sequence_id,
		REVERSED_CASH_RECEIPT_ID=l_cr_id 	/*3328690 */
       WHERE	customer_trx_id = (
   			select customer_trx_id
                           from ar_payment_schedules
                           where class = 'DM'
                           and reversed_cash_receipt_id = l_cr_id
                                   );
    END IF;

    --
    -- added 05-FEB-1996 OSTEINME: determine document number and transaction
    -- number.
    --

    SELECT trx_number
    INTO l_dm_number
    FROM ar_payment_schedules
    WHERE reversed_cash_receipt_id = l_cr_id;
--      AND class = 'DM';

    p_dm_number := l_dm_number;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('debit_memo_reversal: ' || 'dm trx number: ' || l_dm_number);
    END IF;

    -- update cash receipt:

    update_current_cr_rec( p_cr_rec, p_reversal_category,
                         p_reversal_date, p_reversal_reason_code,
                         p_reversal_comments,
                         p_attribute_category, p_attribute1,
                         p_attribute2, p_attribute3, p_attribute4,
                         p_attribute5, p_attribute6, p_attribute7,
                         p_attribute8, p_attribute9, p_attribute10,
                         p_attribute11, p_attribute12, p_attribute13,
                         p_attribute14, p_attribute15 );


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.debit_memo_reversal() -');
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('debit_memo_reversal: ' ||
                       'EXCEPTION: arp_reverse_receipt.debit_memo_reversal' );
              END IF;
              RAISE;
END debit_memo_reversal;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_dm_reversal_args                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to debit_memo_reversal procedure             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |                    p_cc_id - Receipt code combination Id                  |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_reversal_reason_code - Reason for reversal           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_dm_reversal_args(
         p_cr_id     IN ar_cash_receipts.cash_receipt_id%TYPE,
         p_cc_id     IN ra_cust_trx_line_gl_dist.code_combination_id%TYPE,
         p_cust_trx_type_id IN ra_cust_trx_types.cust_trx_type_id%TYPE,
         p_reversal_gl_date  IN
                        ar_cash_receipt_history.reversal_gl_date%TYPE,
         p_reversal_date  IN
                        ar_cash_receipts.reversal_date%TYPE,
         p_reversal_reason_code  IN VARCHAR2) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.validate_dm_reversal_args() +');
    END IF;
    --
    IF ( p_cr_id IS NULL OR p_cc_id IS NULL OR
         p_cust_trx_type_id IS NULL OR p_reversal_gl_date IS NULL OR
         p_reversal_date IS NULL OR p_reversal_reason_code IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_reverse_receipt.validate_dm_reversal_args() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
 	      IF PG_DEBUG in ('Y', 'C') THEN
 	         arp_standard.debug('validate_dm_reversal_args: ' ||
		'EXCEPTION: arp_reverse_receipt.validate_dm_reversal_args' );
 	      END IF;
              RAISE;
--
END validate_dm_reversal_args;
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    receipt_has_non_cancel_claims                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    checks if any claims on receipt cannot be cancelled                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |                    p_include_trx_claims - include invoice related claims  |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | jbeckett 25-MAR-02 Created (bug 2232366)                                  |
 | jbeckett 01-MAY-02 Bug 2353144 - use check_cancel_deduction function to   |
 |                    determine if claim is cancellable                      |
 +===========================================================================*/
FUNCTION receipt_has_non_cancel_claims(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE,
         p_include_trx_claims IN  VARCHAR2 DEFAULT 'Y')
RETURN BOOLEAN
IS
  CURSOR c_claim_count IS
    SELECT count(*)
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_cr_id
    AND    display = 'Y'
    AND    applied_payment_schedule_id = DECODE(p_include_trx_claims,
                                         'N',-4,applied_payment_schedule_id)
    AND    application_ref_type = 'CLAIM';

  CURSOR c_claims IS
    SELECT secondary_application_ref_id
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_cr_id
    AND    display = 'Y'
    AND    applied_payment_schedule_id = DECODE(p_include_trx_claims,
                                         'N',-4,applied_payment_schedule_id)
    AND    application_ref_type = 'CLAIM';
  l_claim_count            NUMBER := 0;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.receipt_has_non_cancel_claims() +');
  END IF;

  OPEN c_claim_count;
  FETCH c_claim_count INTO l_claim_count;
  CLOSE c_claim_count;
  IF l_claim_count = 0
  THEN
    RETURN FALSE;
  END IF;
  FOR c1 in c_claims LOOP
      IF NOT OZF_Claim_GRP.Check_Cancell_Deduction(
                           p_claim_id => c1.secondary_application_ref_id)
      THEN
        RETURN TRUE;
      END IF;
  END LOOP;
  RETURN FALSE;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.receipt_has_non_cancel_claims() -');
  END IF;

END receipt_has_non_cancel_claims;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    cancel_claims                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    cancels all claims on receipt                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |                    p_include_trx_claims - include invoice related claims  |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | jbeckett 25-MAR-02 Created (bug 2232366)                                  |
 | jbeckett 01-MAY-02 Bug 2353144 - use check_cancel_deduction function to   |
 |                    determine if claim is cancellable                      |
 | jbeckett 28-FEB-03 Bug 2751910 - update claims to 0 instead of cancelling |
 +===========================================================================*/
PROCEDURE cancel_claims (p_cr_id IN NUMBER,
                         p_include_trx_claims IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_claim_id             NUMBER;
  l_invoice_ps_id        ar_payment_schedules.payment_schedule_id%TYPE;
  l_claim_reason_code_id NUMBER;
  l_claim_reason_name    VARCHAR2(80);
  l_claim_number         VARCHAR2(30);
  l_customer_trx_id      ra_customer_trx.customer_trx_id%TYPE;
  l_claim_amount         NUMBER;

  CURSOR c_claims IS
    SELECT secondary_application_ref_id,
           application_ref_num,
           applied_payment_schedule_id,
           applied_customer_trx_id,
           amount_applied,
           apply_date
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_cr_id
    AND    display = 'Y'
    AND    applied_payment_schedule_id = DECODE(p_include_trx_claims,
                                         'N',-4,applied_payment_schedule_id)
    AND    application_ref_type = 'CLAIM';

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.cancel_claims() +');
  END IF;
  FOR c1 in c_claims LOOP
    IF OZF_Claim_GRP.Check_Cancell_Deduction(
            p_claim_id => c1.secondary_application_ref_id)
    THEN
      IF c1.applied_payment_schedule_id = -4
      THEN
        l_invoice_ps_id := NULL;
        l_claim_id := c1.secondary_application_ref_id;
        l_claim_amount := 0;
      ELSE
        l_invoice_ps_id := c1.applied_payment_schedule_id;
        l_claim_id := NULL;
        -- Bug 2946734 - invoice claims not zeroized
        SELECT amount_due_remaining
        INTO   l_claim_amount
        FROM   ar_payment_schedules
        WHERE  payment_schedule_id = l_invoice_ps_id;
        l_claim_amount := l_claim_amount + c1.amount_applied;
      END IF;

      arp_process_application.update_claim(
         p_claim_id        =>  l_claim_id
       , p_invoice_ps_id   =>  l_invoice_ps_id
       , p_customer_trx_id =>   c1.applied_customer_trx_id
       , p_amount               =>  l_claim_amount
       , p_amount_applied       =>  c1.amount_applied
       , p_apply_date           =>  c1.apply_date
       , p_cash_receipt_id      =>  p_cr_id
       , p_receipt_number       =>  null
       , p_action_type          =>  'U'
       , x_claim_reason_code_id =>  l_claim_reason_code_id
       , x_claim_reason_name    =>  l_claim_reason_name
       , x_claim_number         =>  l_claim_number
       , x_return_status   =>  x_return_status
       , x_msg_count       =>  x_msg_count
       , x_msg_data        =>  x_msg_data);
      IF x_return_status <> 'S'
      THEN
        RETURN;
      END IF;
    END IF;
  END LOOP;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.cancel_claims() -');
  END IF;
END cancel_claims;
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    receipt_has_claims                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    checks if any claims exist on receipt                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | jbeckett 24-JUN-02 Created (bug 2420941)                                  |
 +===========================================================================*/
FUNCTION receipt_has_claims(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE)
RETURN BOOLEAN
IS
  CURSOR c_claim_count IS
    SELECT count(*)
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_cr_id
    AND    display = 'Y'
    AND    application_ref_type = 'CLAIM';

  l_claim_count            NUMBER := 0;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.receipt_has_claims() +');
  END IF;

  OPEN c_claim_count;
  FETCH c_claim_count INTO l_claim_count;
  CLOSE c_claim_count;
  IF l_claim_count = 0
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.receipt_has_claims() -');
  END IF;

END receipt_has_claims;
--

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_netted_receipts                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    checks if payment netting unapplication will cause netted receipt to go|
 |    negative                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    ar_receipt_val_pvt.validate_unapp_open_receipt                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |                                                                           |
 |              OUT:                                                         |
 |                    x_return_status
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | jbeckett 16-JUL-03 Created (bug 3048023)                                  |
 +===========================================================================*/
PROCEDURE check_netted_receipts(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE,
         x_return_status      OUT NOCOPY VARCHAR2)
IS

  CURSOR c_netted_receipts IS
  SELECT ps.cash_receipt_id, app.amount_applied
  FROM   ar_receivable_applications app,
	 ar_payment_schedules ps
  WHERE  app.applied_payment_schedule_id = ps.payment_schedule_id
  AND    app.cash_receipt_id = p_cr_id
  AND    app.display = 'Y'
  AND    app.receivables_trx_id = -16;

  l_return_status		VARCHAR(1);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_reverse_receipt.check_netted_receipts()+');
  END IF;

  x_return_status := 'S';
  FOR c1 in c_netted_receipts LOOP
      ar_receipt_val_pvt.validate_unapp_open_receipt(
             p_applied_cash_receipt_id => c1.cash_receipt_id,
	     p_amount_applied          => c1.amount_applied,
	     p_return_status 	       => l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 x_return_status := 'E';
         FND_MESSAGE.SET_NAME('AR','AR_RW_NET_RVSL_OVERDRAWS_RCT');
         FND_MSG_PUB.Add;
	 EXIT;
      END IF;
  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_reverse_receipt.check_netted_receipts()-');
  END IF;

EXCEPTION
     WHEN others THEN
          FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',SQLERRM);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION :arp_revers_receipt.check_netted_receipts '||SQLERRM);
     END IF;
END check_netted_receipts;
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    receipt_has_processed_refunds                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    checks if any refunds on receipt cannot be cancelled                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cr_id - Cash receipt ID                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | jbeckett 23-DEC-05 Created (bug 4861233)                                  |
 +===========================================================================*/
FUNCTION receipt_has_processed_refunds(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE)
RETURN BOOLEAN
IS

  CURSOR c_refunds IS
    SELECT application_ref_id
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_cr_id
    AND    display = 'Y'
    AND    applied_payment_schedule_id = -8;
  l_refund_count            NUMBER ;
  l_error_code              VARCHAR2(240);
  l_debug_info		    VARCHAR2(4000);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.receipt_has_processed_refunds() +');
  END IF;

  FOR c1 in c_refunds LOOP
    BEGIN
      IF NOT AP_Cancel_PKG.Is_Invoice_Cancellable(
               P_invoice_id        => c1.application_ref_id,
               P_error_code        => l_error_code,
               P_debug_info        => l_debug_info,
               P_calling_sequence  => 'ARREREVB.receipt_has_processed_refunds') THEN
        RETURN TRUE;
      END IF;
    EXCEPTION WHEN OTHERS THEN
       arp_standard.debug('l_error_code: '||l_error_code);
       arp_standard.debug('l_debug_info: '||l_debug_info);
       arp_standard.debug('Unexpected error encountered calling ap_cancel_pkg.is_invoice_cancellable: '||sqlerrm);
       RETURN TRUE;
    END;
  END LOOP;
  RETURN FALSE;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_reverse_receipt.receipt_has_processed_refunds() -');
  END IF;
END receipt_has_processed_refunds;
--

/*===========================================================================+
 | Function                                                                  |
 |    check_settlement_status                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    checks if receipt settlement is successfuly in IBY, then only allow    |
 |    receipt reversal                                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_extension_id - Paymant Trxn Extension ID             |
 |                                                                           |
 |              RETURN: BOOLEAN                                              |
 |                    TRUE:  Do not allow receipt reversal                   |
 |                    False: Allow receipt reversal                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | SPDIXIT	20-JAN-2009	Created	                                     |
 +===========================================================================*/
FUNCTION check_settlement_status(
         p_extension_id              IN  NUMBER
         )
RETURN BOOLEAN IS
  l_status		NUMBER ;
  l_receipt_status	varchar2(10) := 'N';

Cursor get_receipt_status IS
select 'Y'
from ar_cash_receipts cr
where cr.payment_trxn_extension_id = p_extension_id
and exists (
	Select 1 from xla_transaction_entities
	where entity_code = 'RECEIPTS'
	and nvl(source_id_int_1 , -99) = cr.cash_receipt_id
	and application_id = 222
	and ledger_id = cr.set_of_books_id
	and upg_batch_id is not null ) ;

Cursor get_settlement_status IS
SELECT summ.status
FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
WHERE op.trxn_extension_id = p_extension_id
AND op.transactionid = summ.transactionid
AND summ.reqtype in ('ORAPMTCAPTURE', 'ORAPMTRETURN',
'ORAPMTCREDIT', 'ORAPMTVOID', 'ORAPMTBATCHREQ')
ORDER BY summ.trxnmid desc;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_reverse_receipt.check_settlement_status()+');
  END IF;

  Open get_receipt_status ;
  fetch get_receipt_status into l_receipt_status;
  close get_receipt_status;

  /* Upgraded Receipt - return success */
  IF NVL(l_receipt_status, 'N') = 'Y' THEN
	RETURN FALSE;

  /* Call below code only when receipt is not upgraded. Only for R12 receipts.*/
  Else
	Open get_settlement_status ;
	fetch get_settlement_status into l_status;
	close get_settlement_status;

	if nvl(l_status, -9999)	<> 0 then
	-- This is a error status, so error has to be raised by returning TRUE.
		RETURN TRUE;
	else
	-- Only status = 0 are success cases whose settlement is completed in Payments.
		RETURN FALSE;
	End IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_reverse_receipt.check_settlement_status()-');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Exception: arp_reverse_receipt.check_settlement_status() ' || sqlerrm);
      END IF;
      RETURN TRUE;

END check_settlement_status;


END ARP_REVERSE_RECEIPT;

/
