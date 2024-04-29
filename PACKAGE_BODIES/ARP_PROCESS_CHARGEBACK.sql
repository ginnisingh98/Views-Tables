--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_CHARGEBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_CHARGEBACK" AS
/* $Header: ARCECBB.pls 120.16 2007/01/12 10:14:29 ugummall ship $*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

NULL_VAR ar_payment_schedules%ROWTYPE; /* Added for Bug 460966 - Oracle 8 */
PROCEDURE validate_args_revcb(
			p_cb_ct_id IN ra_customer_trx.customer_trx_id%TYPE,
                        p_reversal_gl_date IN DATE,
                        p_reversal_date IN DATE );

PROCEDURE validate_args_cbrev_ct (
                        p_ct_id IN ra_customer_trx.customer_trx_id%TYPE );

PROCEDURE validate_args_cbrev_group(
                p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_ass_cr_id IN ar_adjustments.associated_cash_receipt_id%TYPE,
                p_ct_count  IN NUMBER );
G_MSG_HIGH  CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH ;

/*===========================================================================+
 | FUNCTION
 |    revision
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package
 |                                                                           |
 | MODIFICATION HISTORY
 |      6/25/1996       Harri Kaukovuo  Created
 +===========================================================================*/

FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.16 $';
END revision;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_chargeback - Reverse a charge back                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function reverses a charge back after checking that it can be done|
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |     arp_process_adjustment.insert_reverse_actions                         |
 |		Setup to reverse an adjustment as part of chargeback reversal|
 |     arp_ps_util.update_reverse_actions                          |
 |		Setup to reverse the payment schedule associated with the    |
 |		chargeback                                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cb_ct_id - Charge back Customer transaction Id          |
 |                 p_reversal_gl_date - Reversal GL date                     |
 |                 p_reversal_date - Reversal Date                           |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |	This procedure is originally converted from C -procedure armrcb
 |	which is in file armcb.lpc.
 |                                                                           |
 | MODIFICATION HISTORY -  04/25/95 - Created by Ganesh Vaidee	     	     |
 |                         05/02/95 - Removed the comment on p_created_from  |
 |				      variable 				     |
 |                         05/02/95 - Assigned 'REVERSE_CHARGEBACK' to       |
 |				      l_adj_rec.created_from variable	     |
 | S.Nambiar 03/23/2001 Modified reverse_chargeback procedure to incorporate |
 |                      the new functionality to create Chargeback aganist   |
 |                      receipts.                                            |
 |                      In case of receipt CB, p_type will be "RECEIPT"      |
 |                      in all other cases it will be defaulted to "TRANSACTION"
 +===========================================================================*/
PROCEDURE reverse_chargeback(
		p_cb_ct_id 		IN ra_customer_trx.customer_trx_id%TYPE,
		p_reversal_gl_date 	IN DATE,
		p_reversal_date 	IN DATE,
		p_module_name 		IN VARCHAR2,
		p_module_version 	IN VARCHAR2,
                p_type                  IN VARCHAR2 DEFAULT 'TRANSACTION' ) IS
l_amount			NUMBER;
l_acctd_amount			NUMBER;
l_ps_id				NUMBER;
--
l_adj_rec			ar_adjustments%ROWTYPE;
--
l_return_code			VARCHAR2(20);
l_app_rec                	arp_global.app_rec_type;
--
l_msg_count             number;
l_msg_data              varchar2(250);
l_return_status         varchar2(10);
l_new_adjustment_number ar_adjustments.adjustment_number%TYPE;
l_new_adjustment_id     ar_adjustments.adjustment_id%TYPE;
l_mesg                  varchar2(250);
adj_api_failure         exception;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_chargeback.reverse_chargeback()+');
       arp_standard.debug('reverse_chargeback: ' ||  to_char( p_cb_ct_id ) );
    END IF;

    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_revcb( p_cb_ct_id, p_reversal_gl_date,
                              p_reversal_date );
    END IF;
    --
    SELECT ps.amount_due_remaining,
	   -ps.amount_due_remaining,
	   ps.acctd_amount_due_remaining,
	   -ps.acctd_amount_due_remaining,
	   ps.payment_schedule_id,
	   ps.associated_cash_receipt_id,
	   NVL( -ps.amount_line_items_remaining, 0 ),
	   NVL( -ps.freight_remaining, 0 ),
	   NVL( -ps.tax_remaining, 0 ),
	   NVL( -ps.receivables_charges_remaining, 0 )
    INTO   l_amount,
	   l_adj_rec.amount,
	   l_acctd_amount,
	   l_adj_rec.acctd_amount,
	   l_ps_id,
	   l_adj_rec.associated_cash_receipt_id,
           l_adj_rec.line_adjusted,
           l_adj_rec.freight_adjusted,
           l_adj_rec.tax_adjusted,
           l_adj_rec.receivables_charges_adjusted
    FROM   ar_payment_schedules ps
    WHERE  ps.customer_trx_id 	= p_cb_ct_id
    AND    ps.class 		= 'CB';

    SELECT dist.code_combination_id
    INTO   l_adj_rec.code_combination_id
    FROM   ra_cust_trx_line_gl_dist dist,
	   ra_customer_trx ct
    WHERE  ct.customer_trx_id = p_cb_ct_id
    AND    ct.customer_trx_id = dist.customer_trx_id
    AND    dist.account_class = 'REV';

    --snambiar - while creating receipt chargebacks,there is no adjustment
    --created. So while reversing,there is no adjustment to reverse. Instead,
    --we need to create an adjustment to adjust the actual chargeback.

    IF p_type <> 'TRANSACTION' THEN
      BEGIN
       --snambiar. For receipt chargeback,we will pass p_type as "RECEIPT"
       --and in all other cases,p_type is defaulted to "TRANSACTION"
       --Here we need to create the adjustment aganist the chargeback.

       l_adj_rec.apply_date :=  p_reversal_date;
       l_adj_rec.gl_date :=  p_reversal_gl_date;
       --
       l_adj_rec.customer_trx_id := p_cb_ct_id;
       --
       l_adj_rec.payment_schedule_id := l_ps_id;
       l_adj_rec.receivables_trx_id := -12;
       l_adj_rec.POSTABLE := 'Y';
       l_adj_rec.type := 'INVOICE';
       l_adj_rec.adjustment_type := 'M';
       --
       l_adj_rec.created_from := 'REVERSE_CHARGEBACK';
       --
       ar_adjust_pub.Create_Adjustment (
                    p_api_name          => 'AR_ADJUST_PUB',
                    p_api_version       => '1',
                    p_init_msg_list     => FND_API.G_TRUE,
                    p_commit_flag       => FND_API.G_FALSE,
                    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                    p_msg_count         => l_msg_count,
                    p_msg_data          => l_msg_data,
                    p_return_status     => l_return_status,
                    p_adj_rec           => l_adj_rec,
                    p_new_adjust_number => l_new_adjustment_number,
                    p_new_adjust_id     => l_new_adjustment_id);

        IF l_return_status <> 'S'
                THEN
                   IF l_msg_count > 1
                   THEN
                      fnd_msg_pub.reset ;
                      l_mesg := fnd_msg_pub.get(p_encoded=>FND_API.G_FALSE);
                      WHILE l_mesg IS NOT NULL
                      LOOP
                        IF PG_DEBUG in ('Y', 'C') THEN
                           arp_util.debug ('reverse_chargeback: ' || l_mesg,G_MSG_HIGH);
                        END IF;
                        l_mesg := fnd_msg_pub.get(p_encoded=>FND_API.G_FALSE);
                      END LOOP ;
                   ELSE
                      l_mesg := l_msg_data ;
                   END IF;

        raise adj_api_failure;

        END IF;

        RETURN;
       EXCEPTION
         WHEN adj_api_failure THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('EXCEPTION: arp_process_chargeback.reverse_chargeback
                                  receipt CB adjustment API failed' );
              END IF;
              RAISE;
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('EXCEPTION: arp_process_chargeback.reverse_chargeback
                                  receipt CB adjustment failed' );
              END IF;
              RAISE;

       END;

    ELSE
       --
       l_adj_rec.apply_date :=  p_reversal_date;
       l_adj_rec.gl_date :=  p_reversal_gl_date;
       --
       l_adj_rec.customer_trx_id := p_cb_ct_id;
       --
       l_adj_rec.payment_schedule_id := l_ps_id;
       l_adj_rec.receivables_trx_id := arp_global.G_CB_REV_RT_ID;
       l_adj_rec.POSTABLE := 'Y';
       l_adj_rec.type := 'INVOICE';
       l_adj_rec.adjustment_type := 'M';
       --
       l_adj_rec.created_from := 'REVERSE_CHARGEBACK';
       --
       arp_process_adjustment.insert_reverse_actions( l_adj_rec, NULL, NULL );
       --
       -- Populate the payment schedule data structure
       --
       l_app_rec.amount_applied := l_amount;
       l_app_rec.line_applied := l_amount;
       l_app_rec.acctd_amount_applied := l_acctd_amount;
       --
       -- Get closed dates
       --
       arp_ps_util.get_closed_dates( l_ps_id, p_reversal_gl_date,
		      p_reversal_date, l_app_rec.gl_date_closed,
		      l_app_rec.actual_date_closed, 'PMT' );
       --
       l_app_rec.ps_id := l_ps_id;
       l_app_rec.trx_type := 'AR_ADJ';
       l_app_rec.user_id := FND_GLOBAL.user_id;
       --
       arp_ps_util.update_reverse_actions( l_app_rec, NULL, NULL);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_chargeback.reverse_chargeback()-');
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('reverse_chargeback: ' ||
		     'EXCEPTION: arp_process_chargeback.reverse_chargeback' );
              END IF;
              RAISE;
END reverse_chargeback;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_revcb                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to reverse_chargeback procedure              |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_cb_ct_id - Charge back Customer transaction Id          |
 |                 p_reversal_gl_date - Reversal GL date                     |
 |                 p_reversal_date - Reversal Date                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_revcb(
			p_cb_ct_id IN ra_customer_trx.customer_trx_id%TYPE,
			p_reversal_gl_date IN DATE,
                        p_reversal_date IN DATE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '>>>>>>>> arp_process_chargeback.validate_args_revcb' );
    END IF;
    --
    IF ( p_cb_ct_id is NULL OR p_reversal_gl_date  is NULL OR
	 p_reversal_date is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '<<<<<<<< arp_process_chargeback.validate_args_revcb' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('validate_args_revcb: ' ||
		     'EXCEPTION: arp_process_chargeback.validate_args_revcb' );
              END IF;
              RAISE;
END validate_args_revcb;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_cb_reversal                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate if a charge back can be reversed                              |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_ps_id  - Payment Schedule Id assocaited with a charge   |
 |			      back					     |
 |                 p_ass_cr_id  - Cash receipt Id associated with a charge   |
 |			      back					     |
 |                 p_ct_count - ???????????? 				     |
 |                 p_module_version - version of module that called the      |
 |				      procedure				     |
 |                 p_module_name - Name of the module that called the proc.  |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : BOOLEAN                 				     |
 |                                                                           |
 | NOTES                                                                     |
 |     This is an ovreloaded procedure                                       |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
FUNCTION validate_cb_reversal (
                p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_ass_cr_id IN ar_adjustments.associated_cash_receipt_id%TYPE,
                p_ct_count  IN NUMBER, p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 ) RETURN BOOLEAN IS
l_sum                   NUMBER DEFAULT 0;
--
l_test_failed           BOOLEAN DEFAULT TRUE;
l_count                 NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_chargeback.validate_cb_reversal()+' );
       arp_standard.debug( to_char( p_ps_id ) );
       arp_standard.debug( to_char( p_ass_cr_id ) );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_cbrev_group( p_ps_id, p_ass_cr_id, p_ct_count );
    END IF;
    --
    -- Validate that the net of applications to the chargeback is zero.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('before BEGIN SELECT NVL in app_delete' );
    END IF;
    SELECT NVL( sum( ra.amount_applied), 0 )
    INTO   l_sum
    FROM   ar_receivable_applications ra
    WHERE  ra.applied_customer_trx_id in (
                SELECT a.chargeback_customer_trx_id
                FROM   ar_adjustments b,
                       ar_adjustments a
                WHERE  a.receivables_trx_id = arp_global.G_CB_RT_ID
                AND    a.associated_cash_receipt_id = p_ass_cr_id
                AND    a.payment_schedule_id = p_ps_id
                AND    b.receivables_trx_id(+) =
                                arp_global.G_CB_REV_RT_ID
                AND    b.customer_trx_id(+) = a.chargeback_customer_trx_id
                AND    b.customer_trx_id is NULL );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before 1st sum' );
       arp_standard.debug(   to_char( l_sum ) );
    END IF;
    IF ( l_sum <> 0 ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(   'Sum of Charge back applications is non-zero');
         END IF;
         l_test_failed := FALSE;
    END IF;
    --
    l_sum := 0;
    --
    -- Validate that the net of adjustments to the chargeback is zero.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'inside SELECT nvl 2nd in app_delete' );
    END IF;
    SELECT NVL( sum( amount ), 0 )
    INTO   l_sum
    FROM   ar_adjustments
    WHERE  customer_trx_id in (
                SELECT a.chargeback_customer_trx_id
                FROM   ar_adjustments a,
                       ar_adjustments b
                WHERE  a.receivables_trx_id = arp_global.G_CB_RT_ID
                AND    a.associated_cash_receipt_id = p_ass_cr_id
                AND    a.payment_schedule_id = p_ps_id
                AND    b.receivables_trx_id(+) =
                                arp_global.G_CB_REV_RT_ID
                AND    b.customer_trx_id(+) = a.chargeback_customer_trx_id
                AND    b.customer_trx_id is NULL )
    AND    NVL( postable, 'Y') = 'Y';
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before 2nd sum' );
       arp_standard.debug(   to_char( l_sum ) );
    END IF;
    --
    IF ( l_sum <> 0 ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(   'Sum of Charge back applications is non-zero');
         END IF;
         l_test_failed := FALSE;
    END IF;
    --
    IF ( l_test_failed = FALSE ) THEN
         RETURN FALSE;
    END IF;
    --
    -- Check if specified chargeback exist
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before SELECT COUNT(*) in app_delete' );
    END IF;
    --
    SELECT count( distinct ct.customer_trx_id )
    INTO   l_count
    FROM   ra_customer_trx ct,
           ar_payment_schedules ps
    WHERE  ct.customer_trx_id in (
                SELECT a.chargeback_customer_trx_id
                FROM   ar_adjustments b,
                       ar_adjustments a
                WHERE  a.receivables_trx_id = arp_global.G_CB_RT_ID
                AND    a.associated_cash_receipt_id = p_ass_cr_id
                AND    a.payment_schedule_id = p_ps_id
                AND    b.receivables_trx_id(+) =
                                arp_global.G_CB_REV_RT_ID
                AND    b.customer_trx_id(+) =
                                a.chargeback_customer_trx_id
                AND    b.customer_trx_id is NULL )
    AND    ps.customer_trx_id = ct.customer_trx_id
    AND    ps.class = 'CB';

    IF ( l_count <> p_ct_count ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(   'passed in count does not match selected count' );
         END IF;
         RETURN FALSE;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_chargeback.validate_cb_reversal()-');
    END IF;
    RETURN TRUE;

    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(
	            'EXCEPTION: arp_process_chargeback.validate_cb_reversal' );
              END IF;
              RAISE;
END validate_cb_reversal;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_cb_reversal                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate if a charge back can be reversed                              |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_ct_id  - Customer Trx ID associated with the charge back|
 |                 p_ct_count - ???????????? 				     |
 |                 p_module_version - version of module that called the      |
 |				      procedure				     |
 |                 p_module_name - Name of the module that called the proc.  |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : BOOLEAN                 				     |
 |                                                                           |
 | NOTES                                                                     |
 |     This is an ovreloaded procedure                                       |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
FUNCTION validate_cb_reversal ( p_ct_id IN ra_customer_trx.customer_trx_id%TYPE,
                                p_module_name IN VARCHAR2,
                                p_module_version IN VARCHAR2 ) RETURN BOOLEAN IS
l_sum                   NUMBER DEFAULT 0;
--
l_test_failed           BOOLEAN DEFAULT TRUE;
l_count                 NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '>>>>>>>> arp_process_chargeback.validate_cb_reversal' );
       arp_standard.debug(    to_char( p_ct_id ) );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_cbrev_ct( p_ct_id );
    END IF;
    --
    BEGIN
        --
        -- Validate that the net of applications to the chargeback is zero.
        --
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'inside BEGIN SELECT NVL in app_delete' );
        END IF;
        SELECT NVL( sum( amount_applied), 0 )
        INTO   l_sum
        FROM   ar_receivable_applications
        WHERE  applied_customer_trx_id = p_ct_id;
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug(
	  	  'arp_process_chargeback.validate_cb_reversal - NO_DATA_FOUND' );
               END IF;
    END;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before 1st sum' );
       arp_standard.debug(   to_char( l_sum ) );
    END IF;
    --
    IF ( l_sum <> 0 ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(   'Sum of Charge back applications is non-zero');
         END IF;
         l_test_failed := FALSE;
    END IF;
    --
    l_sum := 0;
    --
    -- Validate that the net of adjustments to the chargeback is zero.
    --
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'inside SELECT nvl 2nd in app_delete' );
        END IF;
        SELECT NVL( sum( amount ), 0 )
        INTO   l_sum
        FROM   ar_adjustments
        WHERE  customer_trx_id = p_ct_id
        AND    NVL( postable, 'Y') = 'Y';
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug(
			'No data found in RA table - validate_cb_reversal ' );
                 END IF;
    END;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before 2nd sum' );
       arp_standard.debug(   to_char( l_sum ) );
    END IF;
    --
    IF ( l_sum <> 0 ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(   'Sum of Charge back applications is non-zero');
         END IF;
         l_test_failed := FALSE;
    END IF;
    --
    IF ( l_test_failed = FALSE ) THEN
         RETURN FALSE;
    END IF;
    --
    -- Check if specified chargeback exist
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before SELECT COUNT(*) in app_delete' );
    END IF;
    BEGIN
        SELECT count(*)
        INTO   l_count
        FROM   ra_customer_trx ct,
               ar_payment_schedules ps
        WHERE  ct.customer_trx_id = p_ct_id
        AND    ps.customer_trx_id = ct.customer_trx_id
        AND    ps.class = 'CB';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(
		'arp_process_chargeback.validate_cb_reversa - NO_DATA_FOUND' );
            END IF;
         RETURN FALSE;
    END;
   --
   -- At this point, validation is successful. Lock payment schedule recor
   -- and return AR_M_SUCCESS. However, this should be done at a different
   -- level.

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '<<<<<<<< arp_process_chargeback.validate_cb_reversal' );
    END IF;
    RETURN TRUE;
    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(
		      'EXCEPTION: arp_process_chargeback.validate_cb_reversal' );
              END IF;
              RAISE;
END validate_cb_reversal;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_cbrev_ct                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure validates input to validate_cb_reversal procedure       |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_ct_id - Customer Trx ID associated with the charge back |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_cbrev_ct (
                        p_ct_id IN ra_customer_trx.customer_trx_id%TYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_process_chargeback.validate_args_cbrev_ct' );
    IF ( p_ct_id is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    arp_standard.debug( '<<<<<<<< arp_process_chargeback.validate_args_cbrev_ct' );
    EXCEPTION
         WHEN OTHERS THEN
              arp_standard.debug(
		  'EXCEPTION: arp_process_chargeback.validate_args_cbrev_ct' );
              RAISE;
END;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_cbrev_group                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure validates input to validate_cb_reversal procedure       |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_ps_id  - Payment Schedule Id assocaited with a charge   |
 |                            back                                           |
 |                 p_ass_cr_id  - Cash receipt Id associated with a charge   |
 |                            back                                           |
 |                 p_ct_count - ????????????                                 |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_cbrev_group(
                p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_ass_cr_id IN ar_adjustments.associated_cash_receipt_id%TYPE,
                p_ct_count  IN NUMBER ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '>>>>>>>> arp_process_chargeback.validate_args_cbrev_group' );
    END IF;
    IF ( p_ps_id is NULL OR p_ass_cr_id is NULL OR p_ct_count is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '<<<<<<<< arp_process_chargeback.validate_args_cbrev_group' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('validate_args_cbrev_group: ' ||
	       'EXCEPTION: arp_process_chargeback.validate_args_cbrev_group' );
             END IF;
             RAISE;
END validate_args_cbrev_group;

/*===========================================================================+
   PROCEDURE
	validate_args_create_cb()

   DESCRIPTION
	This procedure validates all important parameters that are needed
	in creation of chargebacks.

   SCOPE
	Private

   EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
	arp_util.validate_gl_date()		Validates GL date

   ARGUMENTS
	IN
		p_gl_date
		p_cust_trx_type_id
		p_inv_customer_trx_id
		p_due_date
	OUT

   RETURNS
	Nothing

   NOTES

   MODIFICATION HISTORY
	10/10/1995	H.Kaukovuo	Created
 +===========================================================================*/
PROCEDURE validate_args_create_cb(
  p_gl_date			IN DATE
, p_cust_trx_type_id		IN NUMBER
, p_inv_customer_trx_id		IN NUMBER
, p_due_date			IN DATE
)
IS
l_parameter_tokens		VARCHAR2(100);

BEGIN
  arp_standard.debug('arp_process_chargeback.validate_args_create_cb(+)' );

  l_parameter_tokens := '';

  -- ---------------------------------------------------
  -- Search for invalid parameter. Stop immediately after
  -- invalid parameter value. Display error message.
  -- ---------------------------------------------------

  IF (p_gl_date IS NULL) THEN
    l_parameter_tokens := 'p_gl_date';
  ELSIF (p_cust_trx_type_id IS NULL) THEN
    l_parameter_tokens := 'p_cust_trx_type_id';
  ELSIF (p_inv_customer_trx_id IS NULL) THEN
    l_parameter_tokens := 'p_inv_customer_trx_id';
  ELSIF (p_due_date IS NULL) THEN
    l_parameter_tokens := 'p_due_date';
  END IF;

  -- ---------------------------------------------------
  -- If one ore more variables were invalid, display the error
  -- ---------------------------------------------------
  IF (l_parameter_tokens <> '') THEN
    fnd_message.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    fnd_message.set_token('PARAMETER',l_parameter_tokens);
    fnd_message.set_token('PROCEDURE','ARP_PROCESS_CHARGEBACK.CREATE_CHARGEBACK');
    app_exception.raise_exception;
  END IF;

  arp_standard.debug('arp_process_chargeback.validate_args_create_cb(-)' );

EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug('-- Exception: Others: validate.args_create_cb');
    app_exception.raise_exception;
END;

/*
===========================================================================
PROCEDURE
	init_adj_struct

DESCRIPTION
	Initializes all adjustment variables.
	All numeric variables are set to zero and all text variables are
	set to NULL

NOTE
	Strict conversion from C-code function armnadj() in armadj.lpc.

HISTORY
4/2/1996	Harri Kaukovuo	Created
===========================================================================
*/
PROCEDURE init_adj_struct (
	p_adj_rec	IN OUT NOCOPY AR_ADJUSTMENTS%ROWTYPE) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.init_adj_struct()+');
  END IF;
  p_adj_rec.adjustment_id	:= NULL;
  p_adj_rec.amount		:= 0;
  p_adj_rec.acctd_amount	:= 0;
  p_adj_rec.apply_date		:= NULL;
  p_adj_rec.gl_date		:= NULL;
  p_adj_rec.code_combination_id	:= 0;
  p_adj_rec.customer_trx_id	:= NULL;
  p_adj_rec.customer_trx_line_id:= NULL;
  p_adj_rec.subsequent_trx_id	:= NULL;
  p_adj_rec.payment_schedule_id	:= NULL;
  p_adj_rec.receivables_trx_id	:= NULL;
  p_adj_rec.reason_code		:= NULL;
  p_adj_rec.postable		:= NULL;
  p_adj_rec.type		:= NULL;
  p_adj_rec.adjustment_type	:= NULL;
  p_adj_rec.associated_cash_receipt_id	:= NULL;
  p_adj_rec.line_adjusted	:= NULL;
  p_adj_rec.freight_adjusted	:= NULL;
  p_adj_rec.tax_adjusted	:= NULL;
  p_adj_rec.receivables_charges_adjusted := NULL;
  p_adj_rec.chargeback_customer_trx_id	:= NULL;
  p_adj_rec.created_from	:= NULL;
  p_adj_rec.status		:= NULL;
  p_adj_rec.request_id		:= NULL;
  p_adj_rec.program_update_date	:= NULL;
  p_adj_rec.program_id		:= NULL;
  p_adj_rec.program_application_id := NULL;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.init_adj_struct()-');
  END IF;

END init_adj_struct;

/*
===========================================================================
PROCEDURE
	init_ps_struct

DESCRIPTION
	Initializes all payment schedules variables.
	All numeric variables are set to zero and all text variables are
	set to NULL

NOTE
	Strict conversion from C-code function armnps() in armps.lpc.
	Payment_schedule_id is left NULL because table handler is going to
	populate that value with sequence value.

HISTORY
4/2/1996	Harri Kaukovuo	Created
===========================================================================
*/
PROCEDURE init_ps_struct (
	p_ps_rec	IN OUT NOCOPY AR_PAYMENT_SCHEDULES%ROWTYPE) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.init_ps_struct()+');
  END IF;
  p_ps_rec.payment_schedule_id		:= NULL;
  p_ps_rec.due_date			:= NULL;
  p_ps_rec.amount_due_original		:= NULL;
  p_ps_rec.amount_due_remaining		:= NULL;
  p_ps_rec.acctd_amount_due_remaining	:= NULL;
  p_ps_rec.number_of_due_dates		:= 0;
  p_ps_rec.status			:= NULL;
  p_ps_rec.invoice_currency_code	:= NULL;
--  p_ps_rec.payment_currency_code	:= NULL;
  p_ps_rec.class			:= NULL;
  p_ps_rec.cust_trx_type_id		:= NULL;
  p_ps_rec.customer_id			:= NULL;
  p_ps_rec.customer_site_use_id		:= NULL;
  p_ps_rec.customer_trx_id		:= NULL;
  p_ps_rec.cash_receipt_id		:= NULL;
  p_ps_rec.associated_cash_receipt_id	:= NULL;
  p_ps_rec.term_id			:= NULL;
  p_ps_rec.terms_sequence_number	:= NULL;
  p_ps_rec.gl_date_closed		:= NULL;
  p_ps_rec.actual_date_closed		:= NULL;
  p_ps_rec.discount_date		:= NULL;
  p_ps_rec.amount_line_items_original	:= NULL;
  p_ps_rec.amount_line_items_remaining	:= NULL;
  p_ps_rec.amount_applied		:= NULL;
  p_ps_rec.amount_adjusted		:= NULL;
  p_ps_rec.amount_adjusted_pending	:= NULL;
  p_ps_rec.amount_in_dispute		:= NULL;
  p_ps_rec.amount_credited		:= NULL;
  p_ps_rec.receivables_charges_remaining:= NULL;
  p_ps_rec.freight_original		:= NULL;
  p_ps_rec.freight_remaining		:= NULL;
  p_ps_rec.tax_original			:= NULL;
  p_ps_rec.tax_remaining		:= NULL;
  p_ps_rec.discount_original		:= NULL;
  p_ps_rec.discount_remaining		:= NULL;
  p_ps_rec.discount_taken_earned	:= NULL;
  p_ps_rec.discount_taken_unearned	:= NULL;
  p_ps_rec.in_collection		:= NULL;
  p_ps_rec.reversed_cash_receipt_id	:= NULL;
  p_ps_rec.cash_applied_id_last		:= NULL;
  p_ps_rec.cash_applied_date_last	:= NULL;
  p_ps_rec.cash_applied_amount_last	:= NULL;
  p_ps_rec.cash_applied_status_last	:= NULL;
  p_ps_rec.cash_gl_date_last		:= NULL;
  p_ps_rec.cash_receipt_id_last		:= NULL;
  p_ps_rec.cash_receipt_date_last	:= NULL;
  p_ps_rec.cash_receipt_amount_last	:= NULL;
  p_ps_rec.cash_receipt_status_last	:= NULL;
  p_ps_rec.exchange_rate_type		:= NULL;
  p_ps_rec.exchange_date		:= NULL;
  p_ps_rec.exchange_rate		:= NULL;
  p_ps_rec.adjustment_id_last		:= NULL;
  p_ps_rec.adjustment_date_last		:= NULL;
  p_ps_rec.adjustment_gl_date_last	:= NULL;
  p_ps_rec.adjustment_amount_last	:= NULL;
  p_ps_rec.follow_up_date_last		:= NULL;
  p_ps_rec.follow_up_code_last		:= NULL;
  p_ps_rec.promise_date_last		:= NULL;
  p_ps_rec.promise_amount_last		:= NULL;
  p_ps_rec.collector_last		:= NULL;
  p_ps_rec.call_date_last		:= NULL;
  p_ps_rec.trx_number			:= NULL;
  p_ps_rec.trx_date			:= NULL;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.init_ps_struct()-');
  END IF;

END init_ps_struct;
/*
===========================================================================
PROCEDURE
	init_app_struct

DESCRIPTION
	Initializes all receivable application variables.
	All numeric variables are set to zero and all text variables are
	set to NULL

NOTE
	Strict conversion from C-code function armnapp() in armapp.lpc.
	receivable_application_id is left NULL because table handler is going to
	populate that value with sequence value.

HISTORY
4/2/1996	Harri Kaukovuo	Created
===========================================================================
*/
PROCEDURE init_app_struct (
	p_app_rec	IN OUT NOCOPY AR_RECEIVABLE_APPLICATIONS%ROWTYPE) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.init_app_struct()+');
  END IF;

  p_app_rec.receivable_application_id	:= NULL;
  p_app_rec.amount_applied		:= NULL;
--  p_app_rec.acctd_amount_applied	:= NULL;
  p_app_rec.gl_date			:= NULL;
  p_app_rec.code_combination_id		:= 0;
  p_app_rec.display			:= NULL;
  p_app_rec.apply_date			:= NULL;
  p_app_rec.application_type		:= NULL;
  p_app_rec.status			:= NULL;
  p_app_rec.payment_schedule_id		:= 0;
--  p_app_rec.associated_cash_receipt_id	:= NULL;
  p_app_rec.cash_receipt_id		:= NULL;
  p_app_rec.applied_customer_trx_id	:= NULL;
  p_app_rec.applied_customer_trx_line_id:= NULL;
  p_app_rec.applied_payment_schedule_id	:= NULL;
  p_app_rec.customer_trx_id		:= NULL;
  p_app_rec.line_applied		:= NULL;
  p_app_rec.tax_applied			:= NULL;
  p_app_rec.freight_applied		:= NULL;
  p_app_rec.receivables_charges_applied	:= NULL;
  p_app_rec.on_account_customer		:= NULL;
  p_app_rec.receivables_trx_id		:= NULL;
  p_app_rec.earned_discount_ccid	:= 0;
  p_app_rec.unearned_discount_ccid	:= 0;
  p_app_rec.earned_discount_taken	:= NULL;
  p_app_rec.acctd_earned_discount_taken	:= NULL;
  p_app_rec.unearned_discount_taken	:= NULL;
  p_app_rec.acctd_unearned_discount_taken := NULL;
  p_app_rec.days_late			:= NULL;
  p_app_rec.application_rule		:= NULL;
  p_app_rec.gl_posted_date		:= NULL;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('init_app_struct: ' || 'arp_process_chargeback.init_ps_struct()-');
  END IF;

END init_app_struct;

/*
===========================================================================+
   PROCEDURE
	create_chargeback()

   DESCRIPTION
	This procedure will create a chargeback entry for given
	receipt/invoice pair.
	Procedure  will create one default invoice line for quantity
	of 1 and amount of chargeback amount.

	Assumptions
		- Overapplications and application creation signs
		  should have been checked in client site with
		  ARP_NON_DB_PKG.check_natural_application and
		  ARP_NON_DB_PKG.check_creation_sign procedures.

	The algorithm for creating chargebacks:
	1.  Instantiate variables with default values
	2.  Insert header RA_CUSTOMER_TRX
	3.  Insert one line into RA_CUSTOMER_TRX_LINES
	4.  Insert revenue account GL distribution
	    into RA_CUST_TRX_LINE_GL_DIST
	5.  Insert receivables account GL distribution
	    into RA_CUST_TRX_LINE_GL_DIST
	6.  Insert into AR_PAYMENT_SCHEDULES
		- Call event handler

	7.  Initialize, then populate app_struct and ps_struct

	8.  Update AR_PAYMENT_SCHEDULES
	9.  Initialize variables for inserting a row into AR_ADJUSTMENTS
	10.  Insert into AR_ADJUSTMENTS by calling armiadj

   SCOPE
	Public

   EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
	ARTUGBLB.pls
		- arp_trx_global.system_info.base_currency
		- arp_trx_global.system_info.base_precision
		- arp_trx_global.system_info.base_min_acc_unit
	ARCUTILB.pls
		- validate_gl_date
	ARTITRXB.pls	Table handler for ra_customer_trx
		- insert_p
	ARTICTLB.pls	Table handler for ra_customer_trx_lines
		- insert_p
	ARTILGDB.pls	Table handler ra_cust_trx_line_gl_dist
		- insert_p
	ARTEADJS.pls	Adjustment procedures
		- insert_adjustment

   ARGUMENTS
	IN
	p_amount			Chargeback amount
	p_acctd_amount			Chargeback amount in base currency
	p_cr_trx_number 		Cash receipt number
	p_cash_receipt_id		Cash receipt id
	p_inv_trx_number		Invoice number to which chargeback
					is applied against
	p_inv_customer_trx_id		Invoice ID to which chargeback is
					applied
	p_gl_id_ar_trade		Receivables account code combination
					id

	p_apply_date			AI.APPLY_DATE

	OUT

   RETURNS

   NOTES

   MODIFICATION HISTORY
   10/09/1995	H.Kaukovuo	Created
7/29/1996	Harri Kaukovuo	Bug 386242, term_id was not populated when
				ra_customer_trx row was created.
  7/30/1996	Harri Kaukovuo	Bug fix 386662 document numbering was missing
				from the chargeback adjustment.
   11/17/1997   Genneva Wang    Bug fix 412726 - (1) Creation of Chargeback
                                should give message if GL Account assignment
                                is missing. (2) Returns message if a document
                                sequence has not been created for the
                                Chargeback Adjustment activity.
   09/01/1999   Genneva Wang	Bug fix: 976730 Redefault Chargeback GL Date
				if passed in chargeback GL date is invalid
   03/22/2001   S.Nambiar       Program has been modified to create chargeback
                                aganist receipt,which is a new functionality
                                introduced for iClaim-deduction project. In this
                                case, there won't be any adjustment  created.
   3/26/2001    S.Nambiar       Modified create_chargeback parameter list    |
                                and added p_remit_to_address_id and          |
                                p_bill_to_site_use_id for receipt chargeback |
   09/10/2002   S.Nambiar       Bug 2444737 - Added transaction referece flex
                                fields to create chargeback routine.
   01/15/2003   J.Beckett       Bug 2751910 - added p_internal_notes
   09/23/2004	J.Beckett	Bug 3879127 - p_acctd_amount is ignored and
				the chargeback acctd_amount is recalculated
				with respect to amount_due_remaining of
				originating invoice to ensure the sum of all
				chargebacks does not exceed the original
				invoice and to ensure the chargeback balances
				with the corresponding adjustment.
   05/25/2005   J.Beckett	R12 LE uptake : Added legal_entity_id
+===========================================================================
*/

procedure create_chargeback(
  p_amount			IN NUMBER
, p_acctd_amount		IN NUMBER
, p_trx_date			IN DATE
, p_gl_id_ar_trade		IN NUMBER
, p_gl_date			IN DATE

, p_attribute_category		IN VARCHAR2
, p_attribute1			IN VARCHAR2
, p_attribute2			IN VARCHAR2
, p_attribute3			IN VARCHAR2
, p_attribute4			IN VARCHAR2
, p_attribute5			IN VARCHAR2
, p_attribute6			IN VARCHAR2
, p_attribute7			IN VARCHAR2
, p_attribute8			IN VARCHAR2
, p_attribute9 			IN VARCHAR2
, p_attribute10 		IN VARCHAR2
, p_attribute11 		IN VARCHAR2
, p_attribute12 		IN VARCHAR2
, p_attribute13 		IN VARCHAR2
, p_attribute14 		IN VARCHAR2
, p_attribute15 		IN VARCHAR2
, p_cust_trx_type_id 		IN NUMBER
, p_set_of_books_id 		IN NUMBER
, p_reason_code 		IN VARCHAR2
, p_comments 			IN VARCHAR2
, p_def_ussgl_trx_code_context	IN VARCHAR2
, p_def_ussgl_transaction_code	IN VARCHAR2

-- For AR_PAYMENT_SCHEDULES
, p_due_date			IN DATE
, p_customer_id			IN NUMBER
, p_cr_trx_number		IN VARCHAR2
, p_cash_receipt_id		IN NUMBER
, p_inv_trx_number		IN VARCHAR2
, p_apply_date			IN DATE
, p_receipt_gl_date		IN DATE

-- We get rest of the TRX info with this ID
, p_app_customer_trx_id		IN NUMBER
, p_app_terms_sequence_number	IN NUMBER

, p_form_name			IN VARCHAR2

, p_out_trx_number		OUT NOCOPY VARCHAR2
, p_out_customer_trx_id		OUT NOCOPY NUMBER
, p_doc_sequence_value		IN OUT NOCOPY NUMBER
, p_doc_sequence_id		IN OUT NOCOPY NUMBER
, p_exchange_rate_type          IN VARCHAR2
, p_exchange_date               IN DATE
, p_exchange_rate               IN NUMBER
, p_currency_code               IN VARCHAR2
, p_remit_to_address_id         IN NUMBER DEFAULT 0
, p_bill_to_site_use_id         IN NUMBER DEFAULT 0
--Bug 2444737
, p_interface_header_context            IN VARCHAR2
, p_interface_header_attribute1         IN VARCHAR2
, p_interface_header_attribute2         IN VARCHAR2
, p_interface_header_attribute3         IN VARCHAR2
, p_interface_header_attribute4         IN VARCHAR2
, p_interface_header_attribute5         IN VARCHAR2
, p_interface_header_attribute6         IN VARCHAR2
, p_interface_header_attribute7         IN VARCHAR2
, p_interface_header_attribute8         IN VARCHAR2
, p_interface_header_attribute9         IN VARCHAR2
, p_interface_header_attribute10        IN VARCHAR2
, p_interface_header_attribute11        IN VARCHAR2
, p_interface_header_attribute12        IN VARCHAR2
, p_interface_header_attribute13        IN VARCHAR2
, p_interface_header_attribute14        IN VARCHAR2
, p_interface_header_attribute15        IN VARCHAR2
, p_internal_notes                      IN VARCHAR2 -- bug 2751910
, p_customer_reference                  IN VARCHAR2 -- bug 2751910
, p_legal_entity_id			IN NUMBER   /* R12 LE uptake */
)
IS

l_ct_row			ra_customer_trx%ROWTYPE;
l_ctl_row			ra_customer_trx_lines%ROWTYPE;
l_ctlgd_row			ra_cust_trx_line_gl_dist%ROWTYPE;
l_ps_row			ar_payment_schedules%ROWTYPE;
l_adj_row			ar_adjustments%ROWTYPE;

ln_app_payment_schedule_id	NUMBER;

ln_line_applied			NUMBER;
ln_tax_applied			NUMBER;
ln_freight_applied		NUMBER;
ln_charges_applied		NUMBER;

ln_acctd_amount_applied		NUMBER;
ln_acctd_earned_discount_taken	NUMBER;
ln_acctd_unearned_disc_taken	NUMBER;

-- This stuff is for sequence numbering
L_REC_NAME		  	VARCHAR2(50);
l_sequence_name            	VARCHAR2(500);
l_sequence_id              	NUMBER;
l_sequence_value           	NUMBER;
l_sequence_assignment_id   	NUMBER;

l_receivable_activity_acct      NUMBER;
--
l_chargeback_gl_date		DATE;
l_error_message         	VARCHAR2(128);
l_defaulting_rule_used  	VARCHAR2(50);
l_default_gl_date      		DATE;
error_defaulting_gl_date        EXCEPTION;
l_receivables_trx_id            ar_receivables_trx.receivables_trx_id%TYPE;
l_receipt_method_id             ar_cash_receipts.receipt_method_id%TYPE;
l_remit_bank_acct_use_id        ar_cash_receipts.remit_bank_acct_use_id%TYPE;
l_cr_unapp_ccid                 ar_receivable_applications.code_combination_id%TYPE;
l_inv_rec_ccid                  ra_cust_trx_line_gl_dist.code_combination_id%TYPE;
l_id_dummy                      ar_receivable_applications.code_combination_id%TYPE;
l_bill_to_customer_id           ar_cash_receipts.pay_from_customer%TYPE;
l_cb_activity_ccid              ra_cust_trx_line_gl_dist.code_combination_id%TYPE;
l_actual_ccid                   ra_cust_trx_line_gl_dist.code_combination_id%TYPE;
--Bug2979254
l_ev_rec                        arp_xla_events.xla_events_type;
/* Bug 3879127 */
ln_amount_due_remaining		NUMBER;
ln_acctd_amount_due_remaining   NUMBER;
ln_adr_tmp			NUMBER;
ln_acctd_adr_tmp		NUMBER;
l_acctd_amount			NUMBER;
l_term_end_date                 DATE; /*5084781*/
l_rct_le_id			ar_cash_receipts.legal_entity_id%TYPE; /* R12 LE uptake  */
ln_trx_number                   VARCHAR2(20);/*bug 5550153*/
  --Ajay : raising the business event for chargeback creation

   CURSOR get_parent_ps (p_cust_trx_id IN NUMBER) IS
   SELECT customer_trx_id,
          payment_schedule_id,
          invoice_currency_code,
          due_date,
          amount_in_dispute,
          amount_due_original,
          amount_due_remaining,
          amount_adjusted,
          customer_id,
          customer_site_use_id,
          trx_date,
          amount_credited,
          status
   FROM   ar_payment_schedules
   WHERE  customer_trx_id = p_cust_trx_id;

l_prev_cust_old_state AR_BUS_EVENT_COVER.prev_cust_old_state_tab;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_chargeback.create_chargeback()+');
  END IF;

  l_chargeback_gl_date := p_gl_date;
  -- ----------------------------------------------------------
  -- Redefault Chargeback GL date if it is in a invalid period
  -- ----------------------------------------------------------
  IF  (arp_util.is_gl_date_valid(l_chargeback_gl_date) ) THEN
      null;
  ELSE
      IF (arp_util.validate_and_default_gl_date(
                l_chargeback_gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE) THEN
	    l_chargeback_gl_date := l_default_gl_date;
      ELSE
          RAISE error_defaulting_gl_date;
      END IF;
  END IF;
  --
  -- ---------------------------------------------------
  -- Validate parameters
  -- ---------------------------------------------------

  arp_process_chargeback.validate_args_create_cb(
          l_chargeback_gl_date
        , p_cust_trx_type_id
        , p_app_customer_trx_id
        , p_due_date
        );

  -- ---------------------------------------------------
  -- Set chargeback defaults
  -- ---------------------------------------------------

  -- Initialize records
  init_adj_struct (l_adj_row);
  init_ps_struct (l_ps_row);
--  init_app_struct (l_app_row);

  -- First initialize chargeback header
  -- NOTE that old Forms 2.3 program did the initial insert into
  -- RA_CUSTOMER_TRX already in form level. In client/server model
  -- inserting into RA_CUSTOMER_TRX is done here.

  -- Copy values from the applied transaction

  -- snambiar - p_app_customer_trx_id -4 is used for receipt chargeback
  -- if p_app_customer_trx_id is -4, then fetch the details from
  -- for receipt PS insted of invoice PS

  IF p_app_customer_trx_id <> -4 THEN

   BEGIN
     SELECT
	  ct.exchange_rate_type
        , ct.exchange_date
        , ct.exchange_rate
        , ct.bill_to_customer_id
        , ct.ship_to_customer_id
        , ct.sold_to_customer_id
        , ct.remit_to_address_id
        , ct.bill_to_site_use_id
        , ct.ship_to_site_use_id
        , ct.sold_to_site_use_id
	, ps.PAYMENT_SCHEDULE_ID
        , ct.invoice_currency_code
	, ct.primary_salesrep_id
	, ct.territory_id
        , ctlgd.code_combination_id
  /* Bug 3879127 new values needed for acctd_amount calculation */
	, ps.amount_due_remaining
	, ps.acctd_amount_due_remaining
        , NVL(p_legal_entity_id,ct.legal_entity_id)
	, ct.trx_number /*added for bug 5550153*/
    INTO
	  l_ct_row.exchange_rate_type
	, l_ct_row.exchange_date
	, l_ct_row.exchange_rate
	, l_ct_row.bill_to_customer_id
	, l_ct_row.ship_to_customer_id
	, l_ct_row.sold_to_customer_id
	, l_ct_row.remit_to_address_id
	, l_ct_row.bill_to_site_use_id
	, l_ct_row.ship_to_site_use_id
	, l_ct_row.sold_to_site_use_id
	, ln_app_payment_schedule_id
        , l_ct_row.invoice_currency_code
	, l_ct_row.primary_salesrep_id
	, l_ct_row.territory_id
        , l_inv_rec_ccid
  /* Bug 3879127 */
        , ln_amount_due_remaining
        , ln_acctd_amount_due_remaining
        , l_ct_row.legal_entity_id   /* R12 LE uptake */
        , ln_trx_number /*bug 5550153*/
    FROM
	  ar_payment_schedules 	   ps
        , ra_cust_trx_line_gl_dist ctlgd
	, ra_customer_trx 	   ct
    WHERE
        ct.customer_trx_id = p_app_customer_trx_id
	AND ct.customer_trx_id = ps.customer_trx_id
        AND ct.customer_trx_id = ctlgd.customer_trx_id(+)
        AND ctlgd.account_class = 'REC'
        AND ctlgd.latest_rec_flag = 'Y'
	AND ps.terms_sequence_number	= p_app_terms_sequence_number;

    --Ajay : chargeback creation business event related stuff
      FOR i in get_parent_ps(p_app_customer_trx_id) LOOP
        l_prev_cust_old_state(i.payment_schedule_id).amount_due_remaining := i.amount_due_remaining;
        l_prev_cust_old_state(i.payment_schedule_id).status := i.status;
        l_prev_cust_old_state(i.payment_schedule_id).amount_credited := i.amount_credited;

      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  '-- Exception: Select default values from old invoice');
       arp_standard.debug(  '-- p_app_customer_trx_id='||
			TO_CHAR(p_app_customer_trx_id));
    END IF;
    RAISE;
  END;
 END IF;

 BEGIN
    SELECT
          cr.pay_from_customer
        , cr.receipt_method_id
        , cr.remit_bank_acct_use_id
        , cr.legal_entity_id
    INTO
	  l_bill_to_customer_id
        , l_receipt_method_id
        , l_remit_bank_acct_use_id
        , l_rct_le_id   /* R12 LE uptake */
    FROM
	 ar_cash_receipts 	cr
    WHERE
        cr.cash_receipt_id      = p_cash_receipt_id;
 EXCEPTION
    WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  '-- Exception: Select default values from the receipt');
       arp_standard.debug(  '-- p_cash_receipt_id='|| TO_CHAR(p_cash_receipt_id));
    END IF;
    RAISE;
 END;
  --app_customer_trx_id -4 is passed only in case of chargeback
  IF p_app_customer_trx_id = -4 THEN

	 l_ct_row.bill_to_customer_id  := l_bill_to_customer_id;
	 l_ct_row.remit_to_address_id  := p_remit_to_address_id;
	 l_ct_row.bill_to_site_use_id  := p_bill_to_site_use_id;
         l_ct_row.exchange_rate_type   := p_exchange_rate_type;
         l_ct_row.exchange_date        := p_exchange_date;
         l_ct_row.exchange_rate        := p_exchange_rate;
         l_ct_row.invoice_currency_code:= p_currency_code;

	 l_ct_row.primary_salesrep_id  := NULL;
	 l_ct_row.territory_id         := NULL;
	 l_ct_row.ship_to_customer_id  := NULL;
	 l_ct_row.sold_to_customer_id  := NULL;
	 l_ct_row.ship_to_site_use_id  := NULL;
	 l_ct_row.sold_to_site_use_id  := NULL;
         /* R12 LE uptake */
         l_ct_row.legal_entity_id      := NVL(p_legal_entity_id,l_rct_le_id);
  END IF;

  l_ct_row.customer_trx_id	:= NULL; -- This will be populated when header is inserted
  l_ct_row.trx_date		:= p_trx_date;
  l_ct_row.complete_flag 	:= 'Y';
  l_ct_row.status_trx 		:= 'OP';
  l_ct_row.batch_source_id	:= 12;
  l_ct_row.cust_trx_type_id	:= p_cust_trx_type_id;
  l_ct_row.created_from		:= p_form_name;
  l_ct_row.batch_id 		:= NULL;
  l_ct_row.reason_code		:= p_reason_code;
  l_ct_row.attribute_category	:= p_attribute_category;
  l_ct_row.attribute1		:= p_attribute1;
  l_ct_row.attribute2		:= p_attribute2;
  l_ct_row.attribute3		:= p_attribute3;
  l_ct_row.attribute4		:= p_attribute4;
  l_ct_row.attribute5		:= p_attribute5;
  l_ct_row.attribute6		:= p_attribute6;
  l_ct_row.attribute7		:= p_attribute7;
  l_ct_row.attribute8		:= p_attribute8;
  l_ct_row.attribute9		:= p_attribute9;
  l_ct_row.attribute10		:= p_attribute10;
  l_ct_row.attribute11		:= p_attribute11;
  l_ct_row.attribute12		:= p_attribute12;
  l_ct_row.attribute13		:= p_attribute13;
  l_ct_row.attribute14		:= p_attribute14;
  l_ct_row.attribute15		:= p_attribute15;
  l_ct_row.default_ussgl_trx_code_context := p_def_ussgl_trx_code_context;
  l_ct_row.default_ussgl_transaction_code :=
			p_def_ussgl_transaction_code;
  l_ct_row.doc_sequence_id	:= p_doc_sequence_id;
  l_ct_row.doc_sequence_value	:= p_doc_sequence_value;
  l_ct_row.comments 		:= substrb(p_comments,1,240);
  l_ct_row.internal_notes	:= p_internal_notes;    --Bug 2751910
  l_ct_row.customer_reference	:= p_customer_reference;    --Bug 2751910

 --Bug 2444737
  l_ct_row.interface_header_context      := p_interface_header_context;
  l_ct_row.interface_header_attribute1   := p_interface_header_attribute1;
  l_ct_row.interface_header_attribute2   := p_interface_header_attribute2;
  l_ct_row.interface_header_attribute3   := p_interface_header_attribute3;
  l_ct_row.interface_header_attribute4   := p_interface_header_attribute4;
  l_ct_row.interface_header_attribute5   := p_interface_header_attribute5;
  l_ct_row.interface_header_attribute6   := p_interface_header_attribute6;
  l_ct_row.interface_header_attribute7   := p_interface_header_attribute7;
  l_ct_row.interface_header_attribute8   := p_interface_header_attribute8;
  l_ct_row.interface_header_attribute9   := p_interface_header_attribute9;
  l_ct_row.interface_header_attribute10  := p_interface_header_attribute10;
  l_ct_row.interface_header_attribute11  := p_interface_header_attribute11;
  l_ct_row.interface_header_attribute12  := p_interface_header_attribute12;
  l_ct_row.interface_header_attribute13  := p_interface_header_attribute13;
  l_ct_row.interface_header_attribute14  := p_interface_header_attribute14;
  l_ct_row.interface_header_attribute15  := p_interface_header_attribute15;

  -- ---------------------------------------------------
  -- Insert the customer trx header with the term_id of
  -- of '5' which refers to the 'IMMEDIATE' payment
  -- term of 100% with 0 due dates
  -- ---------------------------------------------------
  l_ct_row.term_id		:= 5;

  -- ---------------------------------------------------
  -- Select the default printing option according to the
  -- transaction type that was passed to the entity handler
  -- --------------------------------------------------

  BEGIN  -- Select printing option
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  '-- Select printing option');
    END IF;

    SELECT NVL(ctt.default_printing_option,'PRI')
         , DECODE(ctt.default_printing_option
                  , 'NOT','N'
                  , 'Y')
            INTO l_ct_row.printing_option,
                 l_ct_row.printing_pending
    FROM  ra_cust_trx_types	ctt
    WHERE ctt.cust_trx_type_id = p_cust_trx_type_id;

/* 5084781 Begin*/
    select end_date_active
           into l_term_end_date
    from ra_terms where term_id = 5;

    IF (NVL(l_term_end_date, to_date('31-12-4712','DD-MM-YYYY')) < p_trx_date ) THEN
         FND_MESSAGE.SET_NAME('AR','AR_RW_PAYMENT_TERM_END_DATED');
         APP_EXCEPTION.raise_exception;
    END IF;
/*5084781 End*/

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  '-- Exception: Select printing option from DB');
         arp_standard.debug(  '-- ctt.cust_trx_type_id='||
			TO_CHAR(p_cust_trx_type_id));
      END IF;
      RAISE;
  END; -- Select printing option

  -- ---------------------------------------------------
  -- Insert header into RA_CUSTOMER_TRX table
  -- ---------------------------------------------------

  -- Call table handler, get trx_number and customer_trx_id back
  -- The main procedure will return trx_number and customer_trx_id
  -- back to calling Form or procedure.
  arp_ct_pkg.insert_p(
	-- IN
	  p_trx_rec		=> l_ct_row
	-- OUT
	, p_trx_number		=> l_ct_row.trx_number
	, p_customer_trx_id	=> l_ct_row.customer_trx_id
	);

  p_out_trx_number 		:= l_ct_row.trx_number;
  p_out_customer_trx_id 	:= l_ct_row.customer_trx_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug (  '-- Transaction number and internal id values returned from');
     arp_standard.debug (  '-- table handler arp_ct_pkg.insert_p:');
     arp_standard.debug (  'trx_number = '||l_ct_row.trx_number);
     arp_standard.debug (  'customer_trx_id = '|| to_char(l_ct_row.customer_trx_id));
     arp_standard.debug (  '');
  END IF;

  -- ---------------------------------------------------
  -- Get line type info for RA_CUSTOMER_TRX_LINES columns
  --  - memo_line_id = 1 means chargeback memo line
  -- ---------------------------------------------------
 IF p_app_customer_trx_id <> -4 THEN
  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  '-- Get line type info');
    END IF;
    SELECT   ml.memo_line_id
           , ml.line_type
           , REPLACE(REPLACE(REPLACE(
	REPLACE(ml.description,'&'||'invoice_number'||'&',ln_trx_number),   ---bug 5550153
                     '&'||'INVOICE_NUMBER'||'&',
                     ln_trx_number),   --- bug 5550153
                    '&'||'receipt_number'||'&',
                    p_cr_trx_number),
                   '&'||'RECEIPT_NUMBER'||'&',
                   p_cr_trx_number)
	, ml.uom_code
    INTO
	  l_ctl_row.memo_line_id
	, l_ctl_row.line_type
	, l_ctl_row.description
	, l_ctl_row.uom_code
    FROM   ar_memo_lines ml
    WHERE  ml.memo_line_id = 1;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  '-- Exception: SELECT FROM AR_MEMO_LINES');
      END IF;
      app_exception.raise_exception;
  END;
 ELSE
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  '-- Get line type info');
     END IF;
    --snambiar in receipt chargeback case,put the receipt details in
    --the description instead of invoice details
  BEGIN
    SELECT   ml.memo_line_id
           , ml.line_type
           , REPLACE(REPLACE(ml.description,'invoice','Receipt number'),'&'||'INVOICE_NUMBER'||'&',p_cr_trx_number)
	   , ml.uom_code
    INTO
	  l_ctl_row.memo_line_id
	, l_ctl_row.line_type
	, l_ctl_row.description
	, l_ctl_row.uom_code
    FROM   ar_memo_lines ml
    WHERE  ml.memo_line_id = 1;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  '-- Exception: SELECT FROM AR_MEMO_LINES');
      END IF;
      app_exception.raise_exception;
  END;
 END IF;

  -- ---------------------------------------------------
  -- Set values for RA_CUSTOMER_TRX_LINES columns
  -- ---------------------------------------------------

  l_ctl_row.customer_trx_id	:= l_ct_row.customer_trx_id;
  l_ctl_row.line_number		:= 1;
  l_ctl_row.taxable_flag	:= 'N';
  l_ctl_row.unit_selling_price	:= p_amount;
  l_ctl_row.quantity_invoiced	:= 1;
  l_ctl_row.extended_amount	:= p_amount;
  l_ctl_row.reason_code		:= p_reason_code;
  l_ctl_row.revenue_amount	:= p_amount;
  -- Copy the default USSGL values to chargeback lines
  l_ctl_row.default_ussgl_transaction_code :=
				l_ct_row.default_ussgl_transaction_code;
  l_ctl_row.default_ussgl_trx_code_context :=
				l_ct_row.default_ussgl_trx_code_context;
  l_ctl_row.set_of_books_id	:= p_set_of_books_id;

  -- ---------------------------------------------------
  -- Insert line into RA_CUSTOMER_TRX_LINES table
  -- ---------------------------------------------------

  arp_ctl_pkg.insert_p(
	-- IN
	  p_line_rec			=> l_ctl_row
	-- OUT
	, p_customer_trx_line_id	=> l_ctl_row.customer_trx_line_id
                  );

  -- ---------------------------------------------------
  -- Insert revenue account distribution
  -- ---------------------------------------------------

  -- ---------------------------------------------------
  -- Set values for RA_CUST_TRX_LINE_GL_DIST table columns
  -- The revenue distributions should have an account class
  -- of 'REV'
  -- ---------------------------------------------------

  l_ctlgd_row.customer_trx_line_id := l_ctl_row.customer_trx_line_id;
  l_ctlgd_row.customer_trx_id      := l_ct_row.customer_trx_id;
  l_ctlgd_row.posting_control_id   := -3;
  l_ctlgd_row.gl_date              := l_chargeback_gl_date;
  l_ctlgd_row.original_gl_date	   := l_chargeback_gl_date;
  l_ctlgd_row.account_class        := 'REV';
  l_ctlgd_row.account_set_flag     := 'N';
  l_ctlgd_row.latest_rec_flag	   := NULL;
  l_ctlgd_row.amount               := p_amount;
  /* Bug 3879127  - acctd_amount is calculated using amount_due_remaining
  of original invoice instead of allowing it to default */
  IF p_app_customer_trx_id = -4
  THEN
    l_acctd_amount := p_acctd_amount;
    /* bug 4126057 set to passed acctd amt instead of null */
  ELSE
    arp_util.calc_acctd_amount(
		  NULL
		, NULL
		, NULL
            	, NVL(l_ct_row.exchange_rate,1)	       -- Exchange rate
            	, '-'          	-- amount_applied must be subtracted from ADR
            	, ln_amount_due_remaining	       -- Current ADR
            	, ln_acctd_amount_due_remaining        -- Current Acctd. ADR
            	, p_amount                             -- Chargeback amount
            	, ln_adr_tmp			       -- New ADR (OUT)
            	, ln_acctd_adr_tmp		       -- New Acctd. ADR (OUT)
            	, l_acctd_amount);                     -- Acct. amount
						       -- (OUT)
  END IF;
  l_ctlgd_row.acctd_amount         := l_acctd_amount;
  l_ctlgd_row.percent              := 100;
  -- Copy the default values to distribution lines
  l_ctlgd_row.ussgl_transaction_code :=
				l_ct_row.default_ussgl_transaction_code;
  l_ctlgd_row.ussgl_transaction_code_context :=
				l_ct_row.default_ussgl_trx_code_context;

  -- ---------------------------------------------------
  -- Get CB_ADJ activity accounting code combination
  -- ---------------------------------------------------
  BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  '-- Get CB_ADJ activity accounting code combination');
      END IF;
      SELECT  rt.code_combination_id
      INTO    l_cb_activity_ccid
      FROM    ar_receivables_trx rt
      WHERE   rt.receivables_trx_id = arp_global.G_CB_RT_ID
      AND     rt.code_combination_id IS NOT NULL;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.set_name('AR', 'AR_RW_NO_GL_ACCT' );
          app_exception.raise_exception;
     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  '-- Exception: select from ar_receivables_trx');
        END IF;
  END;

  l_ctlgd_row.code_combination_id := l_cb_activity_ccid;

  IF p_app_customer_trx_id = -4 THEN
  --Get CCID for receipt UNAPP
    arp_proc_rct_util.get_ccids(
        l_receipt_method_id,
        l_remit_bank_acct_use_id,
        l_id_dummy,
        l_cr_unapp_ccid,
        l_id_dummy,
        l_id_dummy,
        l_id_dummy,
        l_id_dummy,
        l_id_dummy,
        l_id_dummy,
        l_id_dummy,
        l_id_dummy);


   /* -------------------------------------------------------------------+
    | Balancing segment of chargeback application should be replaced with|
    | that of Receipt's UNAPP record                                     |
    +--------------------------------------------------------------------*/
    -- Bugfix 1948917.
    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
    arp_util.Substitute_Ccid(p_coa_id        => arp_global.chart_of_accounts_id   ,
                             p_original_ccid => l_ctlgd_row.code_combination_id   ,
                             p_subs_ccid     => l_cr_unapp_ccid                   ,
                             p_actual_ccid   => l_actual_ccid );
    ELSE
       l_actual_ccid := l_ctlgd_row.code_combination_id;
    END IF;
  ELSE
    -- Regular chargeback should replace the balancing segment of the invoice REC
    -- Bugfix 1948917.
    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
    arp_util.Substitute_Ccid(p_coa_id        => arp_global.chart_of_accounts_id   ,
                             p_original_ccid => l_ctlgd_row.code_combination_id   ,
                             p_subs_ccid     => l_inv_rec_ccid                   ,
                             p_actual_ccid   => l_actual_ccid );
    ELSE
      l_actual_ccid := l_ctlgd_row.code_combination_id;
    END IF;


  END IF;
  l_ctlgd_row.code_combination_id := l_actual_ccid;
  -- ---------------------------------------------------
  -- Insert line into RA_CUST_TRX_LINE_GL_DIST table
  -- ---------------------------------------------------

  arp_ctlgd_pkg.insert_p(
	  -- IN
	  p_dist_rec	  => l_ctlgd_row
	, p_exchange_rate => l_ct_row.exchange_rate
	, p_currency_code => arp_trx_global.system_info.base_currency
	, p_precision     => arp_trx_global.system_info.base_precision
	, p_mau           => arp_trx_global.system_info.base_min_acc_unit
	-- OUT
	, p_cust_trx_line_gl_dist_id
			  => l_ctlgd_row.cust_trx_line_gl_dist_id
	);

  -- ---------------------------------------------------
  -- Insert receivables account distribution
  -- ---------------------------------------------------

  -- ---------------------------------------------------
  -- Set values for RA_CUST_TRX_LINE_GL_DIST table columns
  -- The receivables distributions should have an account class
  -- of 'REC'.
  -- The receivable account distributions records should
  -- not have a value in CUSTOMER_TRX_LINE_ID
  -- ---------------------------------------------------

  l_ctlgd_row.customer_trx_line_id := NULL;
  l_ctlgd_row.customer_trx_id      := l_ct_row.customer_trx_id;
  l_ctlgd_row.posting_control_id   := -3;
  l_ctlgd_row.gl_date              := l_chargeback_gl_date;
  l_ctlgd_row.original_gl_date	   := l_chargeback_gl_date;
  l_ctlgd_row.account_class        := 'REC';
  l_ctlgd_row.account_set_flag     := 'N';
  l_ctlgd_row.latest_rec_flag	   := 'Y';
  l_ctlgd_row.code_combination_id  := p_gl_id_ar_trade;
  l_ctlgd_row.amount               := p_amount;
  l_ctlgd_row.percent              := 100;
  -- Copy the default values to distribution lines
  l_ctlgd_row.ussgl_transaction_code :=
				l_ct_row.default_ussgl_transaction_code;
  l_ctlgd_row.ussgl_transaction_code_context :=
				l_ct_row.default_ussgl_trx_code_context;

  -- ---------------------------------------------------
  -- Insert line into RA_CUST_TRX_LINE_GL_DIST table
  -- ---------------------------------------------------
  arp_ctlgd_pkg.insert_p(
	  -- IN
	  p_dist_rec	  => l_ctlgd_row
	, p_exchange_rate => l_ct_row.exchange_rate
	, p_currency_code => arp_trx_global.system_info.base_currency
	, p_precision     => arp_trx_global.system_info.base_precision
	, p_mau           => arp_trx_global.system_info.base_min_acc_unit
	-- OUT
	, p_cust_trx_line_gl_dist_id
			  => l_ctlgd_row.cust_trx_line_gl_dist_id
	);

  -- ---------------------------------------------------
  -- Set values form AR_PAYMENT_SCHEDULES row.
  --
  -- Insert the payment schedule with the term_id of
  -- of '5' which refers to the 'IMMEDIATE' payment
  -- term of 100% with 0 due dates
  -- ---------------------------------------------------

  l_ps_row.number_of_due_dates		:= 1;
  l_ps_row.status			:= 'OP';
  l_ps_row.class			:= 'CB';
  l_ps_row.cash_receipt_id		:= NULL;
  l_ps_row.term_id			:= 5;
  l_ps_row.terms_sequence_number	:= 1;
  l_ps_row.gl_date_closed		:= NULL;
  l_ps_row.actual_date_closed		:= NULL;
  l_ps_row.discount_date		:= NULL;

  l_ps_row.due_date			:= p_due_date;
  l_ps_row.amount_due_original		:= p_amount;
  l_ps_row.amount_due_remaining		:= p_amount;
  l_ps_row.acctd_amount_due_remaining 	:= l_acctd_amount; -- bug 3879127
  l_ps_row.invoice_currency_code	:= l_ct_row.invoice_currency_code;
  l_ps_row.gl_date			:= l_chargeback_gl_date;
  l_ps_row.cust_trx_type_id		:= p_cust_trx_type_id;
  l_ps_row.customer_id			:= p_customer_id;
  l_ps_row.customer_site_use_id		:= l_ct_row.bill_to_site_use_id;
  l_ps_row.customer_trx_id		:= l_ct_row.customer_trx_id;
  l_ps_row.associated_cash_receipt_id	:= p_cash_receipt_id;
  l_ps_row.amount_line_items_original	:= p_amount;
  l_ps_row.amount_line_items_remaining	:= p_amount;
  l_ps_row.exchange_rate_type		:= l_ct_row.exchange_rate_type;
  l_ps_row.exchange_date		:= l_ct_row.exchange_date;
  l_ps_row.exchange_rate		:= l_ct_row.exchange_rate;
  l_ps_row.trx_number			:= l_ct_row.trx_number;
  l_ps_row.trx_date			:= TRUNC(l_ct_row.trx_date); /* Bug 5758906 */

  -- ---------------------------------------------------
  -- Insert row into AR_PAYMENT_SCHEDULES table
  -- ---------------------------------------------------
  arp_ps_pkg.insert_p(
	  p_ps_rec 	=> l_ps_row			-- IN
	, p_ps_id 	=> l_ps_row.payment_schedule_id	-- OUT
	);

  -- Clear out l_ps_row.payment_schedule_id, because it would
  -- cause chargeback PS row to be updated in
  -- arp_ps_util.update_invoice_related_columms
  l_ps_row.payment_schedule_id		:= NULL;

  ln_line_applied			:= p_amount;
  ln_tax_applied			:= 0;
  ln_freight_applied			:= 0;
  ln_charges_applied			:= 0;
  ln_acctd_amount_applied		:= 0;
  ln_acctd_earned_discount_taken	:= 0;
  ln_acctd_unearned_disc_taken		:= 0;


/*----------------------------------------------
  Calling ARP_XLA_EVENTS to create the CB_CREATE
  ----------------------------------------------*/
   -- BUG#2750340 : Call AR_XLA_EVENTS
   l_ev_rec.xla_from_doc_id   := l_ct_row.customer_trx_id;
   l_ev_rec.xla_to_doc_id     := l_ct_row.customer_trx_id;
   l_ev_rec.xla_req_id        := NULL;
   l_ev_rec.xla_dist_id       := NULL;
   l_ev_rec.xla_doc_table     := 'CT';
   l_ev_rec.xla_doc_event     := NULL;
   l_ev_rec.xla_mode          := 'O';
   l_ev_rec.xla_call          := 'B';
   arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );

/*
  -- ---------------------------------------------------
  -- Updates ar_payment_schedules
  -- ---------------------------------------------------
  arp_ps_util.update_invoice_related_columns(
	-- IN
	  p_app_type			=> 'CB'
	, p_ps_id			=> p_app_customer_trx_id
	, p_amount_applied 		=> p_amount
	, p_discount_taken_earned 	=> 0
	, p_discount_taken_unearned	=> 0
	, p_apply_date			=> p_apply_date
	, p_gl_date			=> l_chargeback_gl_date
        -- OUT
        , p_acctd_amount_applied	=> ln_acctd_amount_applied
        , p_acctd_earned_discount_taken	=> ln_acctd_earned_discount_taken
        , p_acctd_unearned_disc_taken	=> ln_acctd_unearned_disc_taken
        , p_line_applied		=> ln_line_applied
        , p_tax_applied			=> ln_tax_applied
        , p_freight_applied		=> ln_freight_applied
        , p_charges_applied		=> ln_charges_applied
        , p_ps_rec			=> l_ps_row);
*/


  -- ---------------------------------------------------
  -- Set values for AR_ADJUSTMENTS columns
  -- ---------------------------------------------------

  --  Caroline M Clyde            December 23, 1997
  --  Log  597194
  --
  --  Added the SELECT statement below to retrieve the Receivables Activity
  --  Account.  The adjustment should be created with this account and not
  --  the Receivables Account defined on the Transaction Type.
  --
  --  The Receivables Activity for id -11 is the 'Chargeback Adjustment'
  --  activity.

  --snambiar - for receipt chargeback,there is no need to create any
  --adjustments. Hence making adjustment creation conditional for
  --p_app_customer_trx_id -4

 IF (p_app_customer_trx_id <> -4) THEN

  -- Identifier of customer transaction associated with this adjustment
  -- Store the adjusted invoice ID
  l_adj_row.code_combination_id         := l_actual_ccid;
  l_adj_row.customer_trx_id		:= p_app_customer_trx_id;
  l_adj_row.payment_schedule_id		:= ln_app_payment_schedule_id;
  l_adj_row.receivables_trx_id		:= arp_global.G_CB_RT_ID;
  l_adj_row.postable			:= 'Y';

  -- This type is just temporary 'CB' type in order to get
  -- update_adj_related_columns procedure work properly with
  -- chargebacks. If this were 'INVOICE', it would not work because
  -- line adjustment is hard coded to be the full amount of
  -- line_items_amount_due_remaining.
  l_adj_row.type			:= 'CB';

  l_adj_row.adjustment_type		:= 'M';
  l_adj_row.associated_cash_receipt_id	:= p_cash_receipt_id;

  -- Identifier of chargeback transaction associated with this adjustment
  -- Store the corresponding Chargeback ID
  l_adj_row.chargeback_customer_trx_id	:= l_ct_row.customer_trx_id;
  l_adj_row.created_from		:= p_form_name;
  l_adj_row.line_adjusted		:= (ln_line_applied * -1);
  l_adj_row.tax_adjusted		:= (ln_tax_applied * -1);
  l_adj_row.freight_adjusted		:= (ln_freight_applied * -1);
  l_adj_row.receivables_charges_adjusted:= (ln_charges_applied * -1);

  l_adj_row.gl_date			:= TRUNC(l_chargeback_gl_date);
  l_adj_row.apply_date			:= TRUNC(p_apply_date);
  l_adj_row.amount			:= (p_amount * -1);
  l_adj_row.acctd_amount		:= (p_acctd_amount * -1);

  -- Use the old information from Chargeback to populate rest of columns
  l_adj_row.subsequent_trx_id		:= 0;
  l_adj_row.customer_trx_line_id	:= 0;
  l_adj_row.status			:= 'A';
  l_adj_row.automatically_generated	:= 'A';
  l_adj_row.posting_control_id		:= -3;
  l_adj_row.ussgl_transaction_code	:=
		l_ct_row.default_ussgl_transaction_code;
  l_adj_row.ussgl_transaction_code_context :=
		l_ct_row.default_ussgl_trx_code_context;
  l_adj_row.reason_code			:= p_reason_code;
  l_adj_row.comments 			:= p_comments;

  -- -----------------------------------------------------------------
  -- Get document numbers only if customer is using document numbering
  -- -----------------------------------------------------------------
  -- Profile option values:
  --  'A' = always used
  --  'P' = Partially Used
  --  'N' = not used
  IF (NVL(fnd_profile.value('UNIQUE:SEQ_NUMBERS'),'N') <> 'N')
  THEN
      -- Set up sequential numbering stuff
     SELECT rt.name
     INTO   l_rec_name
     FROM   ar_receivables_trx rt
     WHERE  rt.receivables_trx_id = arp_global.G_CB_RT_ID;


     -- Bug 686025/694300: instead of calling GET_SEQ_NAME, use
     -- proper AOL API GET_NEXT_SEQUENCE to get sequence number.

/*
     FND_SEQNUM.GET_SEQ_NAME(
      arp_standard.application_id
      , l_rec_name                     -- category code
      , arp_global.set_of_books_id
      , 'A'
      , l_adj_row.apply_date
      , l_sequence_name
      , l_sequence_id
      , l_sequence_assignment_id);

    l_adj_row.doc_sequence_value :=
              fnd_seqnum.get_next_auto_seq(l_sequence_name);
    l_adj_row.doc_sequence_id := l_sequence_id;

*/

   BEGIN

    l_adj_row.doc_sequence_value :=
       FND_SEQNUM.GET_NEXT_SEQUENCE(
                appid           => arp_standard.application_id,
                cat_code        => l_rec_name,
                sobid           => arp_global.set_of_books_id,
                met_code        => 'A',
                trx_date        => l_adj_row.apply_date,
                dbseqnm         => l_sequence_name,
                dbseqid         => l_adj_row.doc_sequence_id);

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'doc sequence name = '  || l_sequence_name);
        arp_standard.debug(  'doc sequence id    = ' || l_adj_row.doc_sequence_id);
        arp_standard.debug(  'doc sequence value = ' || l_adj_row.doc_sequence_value);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
   --Fix for Bug 1421614: For 'Partial' we should not raise the exception.
     IF NVL(fnd_profile.value('UNIQUE:SEQ_NUMBERS'),'N') = 'A' THEN
         FND_MESSAGE.set_name ('AR', 'AR_RW_NO_DOC_SEQ' );
         APP_EXCEPTION.raise_exception;
     END IF;
   END;

 ELSE
    l_adj_row.doc_sequence_value      := NULL;
    l_adj_row.doc_sequence_id         := NULL;
 END IF;

  -- ---------------------------------------------------
  -- Create adjustment against old invoice
  -- ---------------------------------------------------
  arp_process_adjustment.insert_adjustment(
	-- IN
	  p_form_name 		=> p_form_name
	, p_form_version 	=> 1
	, p_adj_rec 		=> l_adj_row
	-- OUT
	, p_adjustment_number 	=> l_adj_row.adjustment_number
	, p_adjustment_id 	=> l_adj_row.adjustment_id
	);

  -- ---------------------------------------------------
  -- ---------------------------------------------------
  END IF; --for transaction adjustments not required for p_app_customer_trx_id -4
       --Ajay : chargeback creation business event related stuff
          AR_BUS_EVENT_COVER.Raise_Trx_Creation_Event
                                             ('CB',
                                              l_ct_row.customer_trx_id,
                                              l_prev_cust_old_state);

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug ('ARP_PROCESS_CHARGEBACK.CREATE_CHARGEBACK: Exception');
       arp_standard.debug (  'Printing the contents of procedure parameters:');
    END IF;
    -- Print debug info
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug (  ' p_amount			= '||TO_CHAR( p_amount		));
       arp_standard.debug (  ' p_acctd_amount		= '||TO_CHAR( p_acctd_amount	));
       arp_standard.debug (  ' p_trx_date		= '||TO_CHAR( p_trx_date	));
       arp_standard.debug (  ' p_gl_id_ar_trade		= '||TO_CHAR( p_gl_id_ar_trade	));
       arp_standard.debug (  ' p_gl_date		= '||TO_CHAR( l_chargeback_gl_date		));
       arp_standard.debug (  ' p_attribute_category	= '||p_attribute_category	);
       arp_standard.debug (  ' p_attribute1		= '||p_attribute1		);
       arp_standard.debug (  ' p_attribute2		= '||p_attribute2		);
       arp_standard.debug (  ' p_attribute3		= '||p_attribute3		);
       arp_standard.debug (  ' p_attribute4		= '||p_attribute4		);
       arp_standard.debug (  ' p_attribute5		= '||p_attribute5		);
       arp_standard.debug (  ' p_attribute6		= '||p_attribute6		);
       arp_standard.debug (  ' p_attribute7		= '||p_attribute7		);
       arp_standard.debug (  ' p_attribute8		= '||p_attribute8		);
       arp_standard.debug (  ' p_attribute9		= '||p_attribute9		);
       arp_standard.debug (  ' p_attribute10 		= '||p_attribute10 	);
       arp_standard.debug (  ' p_attribute11 		= '||p_attribute11 	);
       arp_standard.debug (  ' p_attribute12 		= '||p_attribute12 	);
       arp_standard.debug (  ' p_attribute13 		= '||p_attribute13 	);
       arp_standard.debug (  ' p_attribute14 		= '||p_attribute14 	);
       arp_standard.debug (  ' p_attribute15 		= '||p_attribute15 	);
       arp_standard.debug (  ' p_cust_trx_type_id	= '||TO_CHAR( p_cust_trx_type_id	));
       arp_standard.debug (  ' p_set_of_books_id	= '||TO_CHAR( p_set_of_books_id	));
       arp_standard.debug (  ' p_reason_code 		= '||p_reason_code 	);
       arp_standard.debug (  ' p_comments		= '||p_comments		);
       arp_standard.debug (  ' p_def_ussgl_trx_code_contex	= '||p_def_ussgl_trx_code_context);
       arp_standard.debug (  ' p_def_ussgl_transaction_cod	= '||p_def_ussgl_transaction_code);
       arp_standard.debug (  ' p_due_date		= '||TO_CHAR( p_due_date		));
       arp_standard.debug (  ' p_customer_id 		= '||TO_CHAR( p_customer_id 	));
       arp_standard.debug (  ' p_cr_trx_number		= '||p_cr_trx_number	);
       arp_standard.debug (  ' p_cash_receipt_id	= '||TO_CHAR( p_cash_receipt_id	));
       arp_standard.debug (  ' p_inv_trx_number		= '||p_inv_trx_number	);
       arp_standard.debug (  ' p_apply_date		= '||TO_CHAR( p_apply_date		));
       arp_standard.debug (  ' p_receipt_gl_date	= '||TO_CHAR( p_receipt_gl_date	));
       arp_standard.debug (  ' p_app_customer_trx_id 	= '||TO_CHAR( p_app_customer_trx_id ));
       arp_standard.debug (  ' p_app_terms_sequence_number 	= '||TO_CHAR( p_app_terms_sequence_number ));
       arp_standard.debug (  ' p_form_name		= '||p_form_name		);
       arp_standard.debug (  ' p_doc_sequence_value	= '||TO_CHAR( p_doc_sequence_value));
       arp_standard.debug (  ' p_doc_sequence_id	= '||TO_CHAR( p_doc_sequence_id));
    END IF;

    RAISE;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_process_chargeback.create_chargeback()-');
    END IF;

END create_chargeback;


/*
===========================================================================+
   PROCEDURE
	update_chargeback()

   DESCRIPTION
	This procedure will update chargeback comments and reason code.
	These are the only allowed updateable columns.

   SCOPE
	Public

   EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

   ARGUMENTS
	IN
		p_customer_trx_id
		p_comments
		p_reason_code

	OUT
		NONE

   RETURNS

   NOTES

   MODIFICATION HISTORY
	4/15/1996	Harri Kaukovuo	Created
+===========================================================================
*/

PROCEDURE update_chargeback (
	  p_customer_trx_id			IN NUMBER
	, p_comments				IN VARCHAR2
	, p_DEFAULT_USSGL_TRX_CODE		IN VARCHAR2
	, p_reason_code				IN VARCHAR2
	, p_ATTRIBUTE_CATEGORY			IN VARCHAR2
	, p_attribute1				IN VARCHAR2
	, p_attribute2				IN VARCHAR2
	, p_attribute3				IN VARCHAR2
	, p_attribute4				IN VARCHAR2
	, p_attribute5				IN VARCHAR2
	, p_attribute6				IN VARCHAR2
	, p_attribute7				IN VARCHAR2
	, p_attribute8				IN VARCHAR2
	, p_attribute9				IN VARCHAR2
	, p_attribute10				IN VARCHAR2
	, p_attribute11				IN VARCHAR2
	, p_attribute12				IN VARCHAR2
	, p_attribute13				IN VARCHAR2
	, p_attribute14				IN VARCHAR2
	, p_attribute15				IN VARCHAR2) IS

l_trx_rec	RA_CUSTOMER_TRX%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.update_chargeback()+');
  END IF;

  -- ---------------------------------------------------
  -- First set all record parameters to dummy
  -- ---------------------------------------------------
  arp_ct_pkg.set_to_dummy (
	l_trx_rec);

  l_trx_rec.customer_trx_id := p_customer_trx_id;
  l_trx_rec.comments := p_comments;
  l_trx_rec.reason_code := p_reason_code;
  l_trx_rec.DEFAULT_USSGL_TRANSACTION_CODE := p_DEFAULT_USSGL_TRX_CODE;
  l_trx_rec.attribute_category 	:= p_attribute_category;
  l_trx_rec.attribute1		:= p_attribute1;
  l_trx_rec.attribute2		:= p_attribute2;
  l_trx_rec.attribute3		:= p_attribute3;
  l_trx_rec.attribute4		:= p_attribute4;
  l_trx_rec.attribute5		:= p_attribute5;
  l_trx_rec.attribute6		:= p_attribute6;
  l_trx_rec.attribute7		:= p_attribute7;
  l_trx_rec.attribute8		:= p_attribute8;
  l_trx_rec.attribute9		:= p_attribute9;
  l_trx_rec.attribute10		:= p_attribute10;
  l_trx_rec.attribute11		:= p_attribute11;
  l_trx_rec.attribute12		:= p_attribute12;
  l_trx_rec.attribute13		:= p_attribute13;
  l_trx_rec.attribute14		:= p_attribute14;
  l_trx_rec.attribute15		:= p_attribute15;

  -- ---------------------------------------------------
  -- Update
  -- ---------------------------------------------------
  arp_ct_pkg.update_p (
  	  l_trx_rec
	, p_customer_trx_id);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug ('arp_process_chargeback.update_chargeback()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug ('EXCEPTION: arp_process_chargeback.update_chargeback()');
       arp_standard.debug (  'ERROR in the program! Dump of parameter values:');
       arp_standard.debug (  ' p_customer_trx_id 	= '||TO_CHAR(p_customer_trx_id));
       arp_standard.debug (  ' p_comments 		= '||p_comments);
       arp_standard.debug (  ' p_DEFAULT_USSGL_TRX_CODE = '||p_DEFAULT_USSGL_TRX_CODE);
       arp_standard.debug (  ' p_reason_code 	= '||p_reason_code);
    END IF;
    RAISE;
END update_chargeback;

/*===========================================================================+
 | PROCEDURE
 |    delete_chargeback
 |
 | DESCRIPTION
 |    This procedure deletes chargeback from database.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |	This procedure is originally converted from C -procedure arxdcb
 |	which is in file arxdcb.lpc
 |
 |	Algorithm:
 |	1. Process parameters
 |	2. Call reverse_chargeback to insert adj and update payment schedule
 |	   of CB
 |	3. Call arp_process_adjustment.reverse_adjustment to insert
 |	   an opposing adjustment for the CB-ADJ
 |	4. Call xxxx to get max GL date and apply date
 |	5. Call xxx to update payment schedule of the debit item.
 |
 | MODIFICATION HISTORY
 |	4/15/1996	Harri Kaukovuo	Created
 |      03/23/2001      S.Nambiar       Modified delete_chargeback procedure
 |                                      to incorporate the new functionality
 |                                      to create Chargeback aganist receipts.
 |                                      In case of receipt CB, p_type will be
 |                                      "RECEIPT" in all other cases it will be
 |                                      defaulted to "TRANSACTION"
 +===========================================================================*/

PROCEDURE delete_chargeback (
	  p_customer_trx_id	IN NUMBER
	, p_apply_date		IN DATE
	, p_gl_date		IN DATE
	, p_module_name		IN VARCHAR2
	, p_module_version	IN VARCHAR2
        , p_type                IN VARCHAR2) IS

ln_adj_id		NUMBER;
ln_adj_amt		NUMBER;
ln_acctd_adj_amt	NUMBER;
ln_line_adj		NUMBER;
ln_tax_adj		NUMBER;
ln_frt_adj		NUMBER;
ln_chrg_adj		NUMBER;
lc_status		VARCHAR2(40);
l_ps_rec		ar_payment_schedules%ROWTYPE;

l_out_line_adjusted		NUMBER;
l_out_tax_adjusted		NUMBER;
l_out_freight_adjusted		NUMBER;
l_out_charges_adjusted		NUMBER;
l_out_acctd_amount_adjusted	NUMBER;
/* New variables defined for bug 2399863 */
l_line_adjusted        NUMBER;
l_tax_adjusted         NUMBER;
l_frt_adjusted         NUMBER;
l_charges_adjusted     NUMBER;

BEGIN

  arp_process_chargeback.reverse_chargeback (
	  p_cb_ct_id		=> p_customer_trx_id
	, p_reversal_gl_date	=> p_gl_date
	, p_reversal_date	=> p_apply_date
	, p_module_name 	=> p_module_name
	, p_module_version	=> p_module_version
        , p_type                => p_type
	);

  arp_ps_pkg.set_to_dummy (l_ps_rec);

 IF p_type <> 'TRANSACTION' THEN
    --snambiar. For receipt chargeback,we will pass p_type as "RECEIPT"
    --and in all other cases,p_type is defaulted to "TRANSACTION"
    --Since we do not have an adjustment created for receipt chargeback,
    --we do not need to reverse the adjustment.
    NULL;
 ELSE
  --chargeback aganist Invoice,CM
  BEGIN
    SELECT
	  adj.adjustment_id
	, adj.payment_schedule_id
	, adj.amount
	, adj.acctd_amount
	, NVL(adj.line_adjusted,0)
	, NVL(adj.tax_adjusted,0)
	, NVL(adj.freight_adjusted,0)
	, NVL(adj.receivables_charges_adjusted,0)
	, adj.status
    INTO
	  ln_adj_id
	, l_ps_rec.payment_schedule_id
	, ln_adj_amt
	, ln_acctd_adj_amt
	, ln_line_adj
	, ln_tax_adj
	, ln_frt_adj
	, ln_chrg_adj
	, lc_status
    FROM    ar_adjustments	adj
    WHERE   adj.chargeback_customer_trx_id = p_customer_trx_id
    AND     adj.receivables_trx_id = -11;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  arp_process_adjustment.reverse_adjustment (
	  P_ADJ_ID 			=> ln_adj_id
	, P_REVERSAL_GL_DATE	 	=> p_gl_date
	, P_REVERSAL_DATE 		=> p_apply_date
	, P_MODULE_NAME 		=> p_module_name
	, P_MODULE_VERSION 		=> p_module_version);

  arp_ps_util.get_closed_dates(
	  p_ps_id 		=> l_ps_rec.payment_schedule_id
	, p_gl_reversal_date 	=> p_gl_date
	, p_reversal_date 	=> p_apply_date
	, p_gl_date_closed	=> l_ps_rec.gl_date_closed	-- OUT
	, p_actual_date_closed	=> l_ps_rec.actual_date_closed	-- OUT
	, p_app_type 		=> 'ADJ');

  /* Bug 2399863
     For reversing the chargeback, pass the p_type as CBREV and
     pass the values for line, tax, frt and charges adjusted */
  l_line_adjusted    := -ln_line_adj;
  l_tax_adjusted     := -ln_tax_adj;
  l_frt_adjusted     := -ln_frt_adj;
  l_charges_adjusted := -ln_chrg_adj;
  arp_ps_util.update_adj_related_columns (
	-- IN
	  p_ps_id			=> l_ps_rec.payment_schedule_id
	, p_type			=> 'CBREV'
	, p_amount_adjusted		=> -ln_adj_amt
	, p_amount_adjusted_pending	=> 0
	, p_apply_date			=> p_apply_date
	, p_gl_date			=> p_gl_date
	, p_ps_rec			=> NULL_VAR  /*Bug 460966 - Oracle 8 */
	-- OUT
	, p_line_adjusted		=> l_line_adjusted
	, p_tax_adjusted		=> l_tax_adjusted
	, p_freight_adjusted		=> l_frt_adjusted
	, p_charges_adjusted		=> l_charges_adjusted
	, p_acctd_amount_adjusted	=> l_out_acctd_amount_adjusted
	);
       l_out_line_adjusted    := l_line_adjusted;
       l_out_tax_adjusted     := l_tax_adjusted;
       l_out_freight_adjusted := l_frt_adjusted;
       l_out_charges_adjusted := l_charges_adjusted;
 END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug ('EXCEPTION: arp_process_chargeback.delete_chargeback()');
       arp_standard.debug ('delete_chargeback: ' || 'ERROR in the program! Dump of parameter values:');
       arp_standard.debug ('delete_chargeback: ' || ' p_customer_trx_id 	= '|| TO_CHAR(p_customer_trx_id));
       arp_standard.debug ('delete_chargeback: ' || ' p_gl_date		= '|| TO_CHAR(p_gl_date));
       arp_standard.debug ('delete_chargeback: ' || ' p_apply_date		= '|| TO_CHAR(p_apply_date));
       arp_standard.debug ('delete_chargeback: ' || ' p_module_name		= '|| p_module_name);
       arp_standard.debug ('delete_chargeback: ' || ' p_module_version	= '|| p_module_version);
    END IF;
    RAISE;

END delete_chargeback;


END ARP_PROCESS_CHARGEBACK;

/
