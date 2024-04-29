--------------------------------------------------------
--  DDL for Package Body ARP_CALCULATE_DISCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CALCULATE_DISCOUNT" AS
/* $Header: ARRUDISB.pls 120.24.12010000.8 2010/02/10 14:25:41 rvelidi ship $ */
--
error_code                   NUMBER;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*PROCEDURE get_discount_percentages(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE
     );
PROCEDURE get_payment_schedule_info(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE
     );
*/
PROCEDURE get_best_discount_percentage(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE
     );

PROCEDURE get_current_discount_percent(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE
     );

--PROCEDURE correct_lines_only_discounts(
--    p_disc_rec IN OUT NOCOPY discount_record_type,
--    p_ps_rec IN ar_payment_schedules%ROWTYPE );
PROCEDURE decrease_discounts_to_adr(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER);
--PROCEDURE determine_max_allowed_disc(
 --   p_mode IN number,
  --  p_disc_rec IN OUT NOCOPY discount_record_type,
   -- p_ps_rec IN ar_payment_schedules%ROWTYPE );
/*FP bug 5335376 for 5223829 Leftover changes of bug for case of system option partial discount unchecked*/
PROCEDURE calculate_direct_discount(
    p_mode IN number,
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER,
    p_called_from IN varchar2 default 'AR');
/*FP bug 5335376 for 5223829 Leftover changes of bug for case of system option partial discount unchecked*/
PROCEDURE calculate_default_discount(
    p_mode IN number,
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER,
    p_out_amt_to_apply IN OUT NOCOPY NUMBER,
    p_called_from IN varchar2 default 'AR' );
PROCEDURE check_input(
    p_disc_rec IN  discount_record_type,
    p_select_flag     IN BOOLEAN,
    p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE );
PROCEDURE decrease_discounts_to_maxd(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER);
--
--
PROCEDURE validate_args_discounts_cover(
     p_mode          IN VARCHAR2,
     p_invoice_currency_code IN ar_cash_receipts.currency_code%TYPE,
     p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
     p_trx_date IN ar_payment_schedules.trx_date%TYPE,
     p_apply_date IN ar_cash_receipts.receipt_date%TYPE );
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calculate_discounts                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calculate Discounts                                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_select_flag - Select Flag                          |
 |                      p_mode  - Mode                                       |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                         |
 |			p_ps_rec - Payment Schedule Record                   |
 |									     |
 |              OUT:                                                         |
 | 								             |
 | 									     |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |  26-Feb-1998    Debbie Jancis     Added cash_receipt_id to arguments as   |
 |                                   per cpg bug 627518.                     |
 |  10-APR-2000    skoukunt          Fix bug 1164810, default amount applied |
 |                                   when the profile AR: Cash Default Amount|
 |                                   Applied OPTION set to Remaining Amount  |
 |                                   of the Invoice                          |
 |  04/25/02   S.Nambiar             Bug 2334691 - If the discount on partial
 |                                   payment flag is 'Y' in system option, then
 |                                   check the partial payment flag on payment
 |                                   term,and take the flag from payment term. But
 |                                   if the flag is 'N' in system option, then
 |                                   no matter what payment term flag says,partial
 |                                   discounts should not be allowed.        |
 |                                   corrected the issue caused by 2144705   |
 |                                                                           |
 +===========================================================================*/
--
/*FP bug 5335376 for 5223829 introduced new parameters*/
PROCEDURE calculate_discounts (
        p_input_amt         IN NUMBER,
        p_grace_days         IN NUMBER,
        p_apply_date         IN DATE,
        p_disc_partial_pmt_flag IN VARCHAR2,
        p_calc_disc_on_lines IN VARCHAR2,
        p_earned_both_flag IN VARCHAR2,
        p_use_max_cash_flag IN VARCHAR2,
        p_default_amt_app IN VARCHAR2,
        p_earned_disc_pct IN OUT NOCOPY NUMBER,
        p_best_disc_pct IN OUT NOCOPY NUMBER,
        p_out_earned_disc IN OUT NOCOPY NUMBER,
        p_out_unearned_disc IN OUT NOCOPY NUMBER,
        p_out_discount_date IN OUT NOCOPY DATE,
        p_out_amt_to_apply IN OUT NOCOPY NUMBER,
        p_close_invoice_flag IN VARCHAR2,
        p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_term_id IN ar_payment_schedules.term_id%TYPE,
        p_terms_sequence_number IN ar_payment_schedules.terms_sequence_number%TYPE,
        p_trx_date IN ar_payment_schedules.trx_date%TYPE,
        p_amt_due_original IN ar_payment_schedules.amount_due_original%TYPE,
        p_amt_due_remaining IN ar_payment_schedules.amount_due_remaining%TYPE,
        p_disc_earned IN ar_payment_schedules.discount_taken_earned%TYPE,
        p_disc_unearned IN ar_payment_schedules.discount_taken_unearned%TYPE,
        p_lines_original IN ar_payment_schedules.amount_line_items_original%TYPE,
        p_invoice_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
	p_select_flag     IN VARCHAR2,
        p_mode IN NUMBER,
        p_error_code IN OUT NOCOPY NUMBER,
        p_cash_receipt_id IN NUMBER,
        p_called_from IN VARCHAR2,
        p_amt_in_dispute IN ar_payment_schedules.amount_in_dispute%TYPE) IS
--
    l_ps_rec         ar_payment_schedules%ROWTYPE;
    l_disc_rec                 discount_record_type;
    l_select_flag                     BOOLEAN;
    l_precision                       NUMBER;
    l_ext_precision                   NUMBER;
    l_min_acct_unit                   NUMBER;
    l_format_mask		      VARCHAR2(100);
    l_sys_disc_partial_pay_flag       VARCHAR2(1) := 'N';
--
BEGIN
--
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'arp_calculate_discount.calculate_discounts() +' );
    END IF;
  -- ARTA Changes, calles TA version of calculate discount for TA
  -- installation
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
     NULL; -- Do Nothing
     -- Removed ARTA changes for Bug 4936298
  ELSE
    IF (p_mode = AR_DIRECT_DISC OR p_mode = AR_DIRECT_NEW_DISC)
    THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'MODE: DIRECT' );
        END IF;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'MODE: DEFAULT' );
        END IF;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'p_default_amt_app:'||p_default_amt_app );
       arp_standard.debug(   'p_earned_both_flag:'||p_earned_both_flag );
       arp_standard.debug(   'p_earned_disc_pct:'||p_earned_disc_pct );
    END IF;
    --
    l_disc_rec.input_amt := p_input_amt;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Input amt = '||TO_CHAR( p_input_amt ) );
    END IF;
    --IF ( p_grace_days IS  NOT NULL ) THEN
    l_disc_rec.grace_days := p_grace_days;
    --END IF;
    l_disc_rec.apply_date := p_apply_date;
    l_disc_rec.disc_partial_pmt_flag := p_disc_partial_pmt_flag;
    l_disc_rec.calc_disc_on_lines := p_calc_disc_on_lines;
    l_disc_rec.earned_both_flag := p_earned_both_flag;
    l_disc_rec.use_max_cash_flag := p_use_max_cash_flag;
    l_disc_rec.default_amt_app := p_default_amt_app;
    l_disc_rec.earned_disc_pct := p_earned_disc_pct;
    l_disc_rec.best_disc_pct := p_best_disc_pct;
    l_disc_rec.out_earned_disc := p_out_earned_disc;
    l_disc_rec.out_unearned_disc := p_out_unearned_disc;
    l_disc_rec.out_discount_date := p_out_discount_date;
    l_disc_rec.out_amt_to_apply := p_out_amt_to_apply;
    l_disc_rec.close_invoice_flag := p_close_invoice_flag;
    l_ps_rec.payment_schedule_id := p_payment_schedule_id;
    l_ps_rec.term_id := p_term_id;
    l_ps_rec.terms_sequence_number := p_terms_sequence_number;
    l_ps_rec.trx_date := p_trx_date;
    l_ps_rec.amount_due_original := p_amt_due_original;
    l_ps_rec.amount_due_remaining := p_amt_due_remaining;
    l_ps_rec.discount_taken_earned := p_disc_earned;
    l_ps_rec.discount_taken_unearned :=  p_disc_unearned;
    l_ps_rec.amount_line_items_original := p_lines_original;
    l_ps_rec.invoice_currency_code := p_invoice_currency_code;
    l_ps_rec.payment_schedule_id := p_payment_schedule_id;
/*FP bug 5335376 for Bug 5223829 set the values as per call from iReceivables*/
    IF p_called_from = 'OIR' Then
      l_ps_rec.amount_in_dispute := p_amt_in_dispute;
    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'p_close_invoice_flag:'||p_close_invoice_flag );
    END IF;

    -- Check input(ardckin). Exit with error if not all needed fields are
    -- populated.
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(   'error_code = '||TO_CHAR( error_code ));
         END IF;
    --   p_error_code := AR_M_FAILURE ;
    --   arp_standard.debug( 'p_error_code = '||TO_CHAR( p_error_code )) ;
    --   RETURN;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'l_ps_rec.amount_due_remaining := '||
		TO_CHAR(l_ps_rec.amount_due_remaining ));
    END IF;

    IF (p_select_flag = 'Y')
    THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'l_select_flag: TRUE' );
        END IF;
        l_select_flag := TRUE;
        get_payment_schedule_info ( l_disc_rec, l_ps_rec );
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'l_select_flag: FALSE' );
        END IF;
        l_select_flag := FALSE;
    END IF;

    check_input( l_disc_rec, l_select_flag, l_ps_rec) ;

    -- 1/29/1996 H.Kaukovuo	Removed p_select_flag
    get_discount_percentages (l_disc_rec, l_ps_rec);

    -- Correct percentages for lines-only(ardline) discount if necessary.
    IF l_disc_rec.calc_disc_on_lines <> 'I' AND
       l_disc_rec.calc_disc_on_lines <> 'N'
    THEN
        correct_lines_only_discounts ( l_disc_rec, l_ps_rec );
    END IF;
    --
    -- If no discount percentages, set discounts to zero.
    IF ( l_disc_rec.best_disc_pct = 0 ) THEN
        p_out_earned_disc := 0 ;
        p_out_unearned_disc := 0 ;
        l_disc_rec.earned_disc_pct := 0;
        --
        -- If in direct calculation mode, exit now.
        IF  p_mode = AR_DIRECT_DISC OR p_mode = AR_DIRECT_NEW_DISC
        THEN
            p_earned_disc_pct := l_disc_rec.earned_disc_pct;
            p_best_disc_pct := l_disc_rec.best_disc_pct;
            p_out_discount_date := l_disc_rec.out_discount_date;
            --p_error_code := AR_M_SUCCESS;
            RETURN;
        END IF;
    --
    END IF;
    --
    -- Calculate maximum remaining discount(ardmaxd) that may be taken for
    -- this ps.
    determine_max_allowed_disc ( p_mode, l_disc_rec, l_ps_rec );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'l_disc_rec.max_disc = '||
                         TO_CHAR( l_disc_rec.max_disc ) );
    END IF;
    --
    --
    -- Calculate discount amounts(ardcdir and ardcdef).
    IF ( p_mode = AR_DIRECT_DISC OR p_mode = AR_DIRECT_NEW_DISC ) THEN
      -- Added the condition to fix bug 1236196
      IF l_disc_rec.max_disc = 0 THEN
         p_out_earned_disc := 0;
         p_out_unearned_disc := 0;
      ELSE
      /*FP bug 5335376 for Bug 5223829 Leftover changes of bug for case of system option partial discount unchecked*/
        calculate_direct_discount ( p_mode,
                                    l_disc_rec,
                                    l_ps_rec,
                                    p_out_earned_disc, p_out_unearned_disc,p_called_from );
      /*Start FP Bug-5741063 Base Bug- 53866459 extended fix to call procedure to decrease discount as per max allowed */
        decrease_discounts_to_maxd(l_disc_rec, l_ps_rec, p_out_earned_disc,p_out_unearned_disc );
      END IF;
    ELSIF ( p_mode = AR_DEFAULT_DISC OR p_mode = AR_DEFAULT_NEW_DISC) THEN
/*FP bug 5335376 for Bug  5223829 Leftover changes of bug for case of system option partial discount unchecked
  Passed newly introduced parameter p_called_from*/

        calculate_default_discount ( p_mode,
                                     l_disc_rec,
                                     l_ps_rec,
                                     p_out_earned_disc, p_out_unearned_disc,
                                     p_out_amt_to_apply,p_called_from );
        /*Start FP Bug-5741063 Bug 5386459 extended fix to call procedure to decrease discount as per max allowed */
        decrease_discounts_to_maxd(l_disc_rec, l_ps_rec, p_out_earned_disc,p_out_unearned_disc );
        --
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'p_out_earned_disc = '||TO_CHAR( p_out_earned_disc ));
           arp_standard.debug(   'p_out_unearned_disc = '||TO_CHAR( p_out_unearned_disc ));
           arp_standard.debug(   'p_out_amt_to_apply = '||TO_CHAR( p_out_amt_to_apply ));
        END IF;
    --
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'Unknown Mode ' );
        END IF;
        RAISE ar_m_fail;
        --p_error_code := AR_M_FAILURE ;
        --RETURN;
    END IF;
    --
    -- Decrease the discounts as necessary to avoid overpaying, to a limit
    -- of zero(ardadr). This is not necessary in default mode.
    IF ( (p_mode = AR_DIRECT_DISC OR p_mode = AR_DIRECT_NEW_DISC) AND
         l_disc_rec.use_max_cash_flag = 'Y' ) THEN
        decrease_discounts_to_adr ( l_disc_rec,
                                    l_ps_rec,
                                    p_out_earned_disc, p_out_unearned_disc);
    END IF;
    --
    SELECT DECODE( fc.minimum_accountable_unit,
                   NULL, ROUND( p_out_earned_disc, fc.precision ),
                   ROUND( p_out_earned_disc/fc.minimum_accountable_unit ) *
                        ( fc.minimum_accountable_unit )
                 ),
           DECODE( fc.minimum_accountable_unit,
                   NULL, ROUND( p_out_unearned_disc, fc.precision ),
                   ROUND( p_out_unearned_disc/fc.minimum_accountable_unit ) *
                        ( fc.minimum_accountable_unit )
                 ),
           DECODE( fc.minimum_accountable_unit,
                   NULL, ROUND( p_out_amt_to_apply, fc.precision ),
                   ROUND( p_out_amt_to_apply/fc.minimum_accountable_unit ) *
                        ( fc.minimum_accountable_unit )
                 )
    INTO p_out_earned_disc,
         p_out_unearned_disc,
         p_out_amt_to_apply
    FROM fnd_currencies fc
    WHERE fc.currency_code = l_ps_rec.invoice_currency_code;
    --
    IF  (p_mode = AR_DEFAULT_DISC OR p_mode = AR_DEFAULT_NEW_DISC)
    THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'amt_due_remaining = '||TO_CHAR( l_ps_rec.amount_due_remaining ) );
        END IF;
        -- Fix bug 1164810, default amount applied when the profile
        -- AR: Cash - Default Amount Applied OPTION is set to
        -- Remaining Amount of the Invoice
        IF p_default_amt_app <> 'PMT' and p_close_invoice_flag = 'Y'
        THEN
          IF ( p_input_amt < 0 ) THEN
            p_out_amt_to_apply := l_ps_rec.amount_due_remaining - p_out_earned_disc;
          ELSE
	  -- Fix bug 1662462 , default amount applied when the profile
	  -- AR: Cash -Default Amount Applied OPTION is set to
	  -- Remaining Amount of the invoice and the input amount
	  -- is positive
            IF (l_ps_rec.amount_due_remaining - p_out_earned_disc) <= p_input_amt
            THEN
                p_out_amt_to_apply := l_ps_rec.amount_due_remaining - p_out_earned_disc;
            ELSE
                --
                -- p_amt_due_remaining >= p_input_amt
                --
                  --  p_out_amt_to_apply := p_input_amt - p_out_earned_disc;
                --begin 2144705
                     p_out_amt_to_apply := p_input_amt ;

                /*For bug 2147188 populating the  partial_pmt_flag correctly to
                  calculate the discount correctly*/

                SELECT arp_standard.sysparm.partial_discount_flag
		INTO l_sys_disc_partial_pay_flag
		FROM dual;

               /*--------------------------------------------------------------------+
                |Bug 2334691 - If partial discount flag in system option is 'N' then |
                |l_disc_rec.disc_partial_pmt_flag= 'N' , if discount flag is 'Y' on  |
                |system option, then take the value from payment terms record        |
                *--------------------------------------------------------------------*/

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug(   'Partial Discount flag System Options = '|| l_sys_disc_partial_pay_flag);
	           arp_standard.debug(   'Partial Discount flag Payment Term = '|| l_disc_rec.disc_partial_pmt_flag);
	        END IF;

                IF NVL(l_sys_disc_partial_pay_flag,'N') = 'N' THEN
                   l_disc_rec.disc_partial_pmt_flag := 'N';
                ELSE
                     null;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug(   'Partial Discount flag - Final  = '|| l_disc_rec.disc_partial_pmt_flag);
                END IF;

                IF NVL(l_disc_rec.disc_partial_pmt_flag,'N')= 'Y' then
                 SELECT DECODE( fc.minimum_accountable_unit,
                        NULL, ROUND( ((p_out_earned_disc/(l_ps_rec.amount_due_remaining-p_out_earned_disc))
                                                                        *p_input_amt), fc.precision ),
                          ROUND( ((p_out_earned_disc/(l_ps_rec.amount_due_remaining-p_out_earned_disc))
                                                                         *p_input_amt)
                                   /fc.minimum_accountable_unit ) *
                               ( fc.minimum_accountable_unit )
                            )
                 INTO p_out_earned_disc
                 FROM fnd_currencies fc
                 WHERE fc.currency_code = l_ps_rec.invoice_currency_code;
               else
                  p_out_earned_disc :=0;
               end if;
                --end 2144705
            END IF;
          END IF;
        -- Not sure if at anytime the control comes to the below conditions
        ELSIF  p_close_invoice_flag = 'Y'
        THEN
        -- ignore the input amount if the close invoice flag = 'Y'
            p_out_amt_to_apply := l_ps_rec.amount_due_remaining - p_out_earned_disc;
        ELSIF p_default_amt_app <> 'PMT'
        THEN
            IF l_ps_rec.amount_due_remaining < p_input_amt
            THEN
                p_out_amt_to_apply := l_ps_rec.amount_due_remaining - p_out_earned_disc;
            ELSE
                --
                -- p_amt_due_remaining >= p_input_amt
                --
                    p_out_amt_to_apply := p_input_amt - p_out_earned_disc;
            END IF;
        END IF;

/*
        -- ignore the input amount if the close invoice flag = 'Y'
        IF p_close_invoice_flag = 'Y'
        THEN
            p_out_amt_to_apply := l_ps_rec.amount_due_remaining - p_out_earned_disc;
        ELSIF p_default_amt_app <> 'PMT'
        THEN
            IF l_ps_rec.amount_due_remaining < p_input_amt
            THEN
                p_out_amt_to_apply := l_ps_rec.amount_due_remaining - p_out_earned_disc;
            ELSE
                --
                -- p_amt_due_remaining >= p_input_amt
                --
                    p_out_amt_to_apply := p_input_amt - p_out_earned_disc;
            END IF;
        END IF;
*/
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'earned_disc = '||TO_CHAR( p_out_earned_disc ) );
       arp_standard.debug(   'Unearned_disc = '||TO_CHAR( p_out_unearned_disc ) );
       arp_standard.debug(   'Amount to Apply = '||TO_CHAR( p_out_amt_to_apply ) );
    END IF;
    --
    p_earned_disc_pct := l_disc_rec.earned_disc_pct;
    p_best_disc_pct := l_disc_rec.best_disc_pct;
    p_out_discount_date := l_disc_rec.out_discount_date;
    --p_error_code := AR_M_SUCCESS;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'p_error_code := '||p_error_code );
    END IF;
  END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'arp_calculate_discount.calculate_discounts() -' );
    END IF;
    --
    EXCEPTION
    	WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug(   'Exception: arp_calculate_discount.calculate_discounts()' );
           END IF;
        --IF (error_code IS NOT NULL) THEN
        --p_error_code := error_code;
        --RETURN;
        --ELSE
	   RAISE;
        --END IF;
END calculate_discounts;
--
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_discount_percentages                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Get Discount Percentages                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                      p_ps_rec - Payment Schedule Record  |
 |								             |
 |              OUT:                          			             |
 |								             |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 | 1/29/1996	Harri Kaukovuo	Modified comments and clarified program
 |				out NOCOPY look. Removed obsolete parameter
 |				P_SELECT_FLAG.
 +===========================================================================*/
PROCEDURE get_discount_percentages(
    p_disc_rec  	IN OUT NOCOPY arp_calculate_discount.discount_record_type,
    p_ps_rec    	IN OUT NOCOPY ar_payment_schedules%ROWTYPE
     ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'arp_calculate_discount.'||
		'get_discount_percentages()+' );
    END IF;

    -- ----------------------------------------------------------------
    -- Get the best discount percentage.
    -- ----------------------------------------------------------------
    get_best_discount_percentage (p_disc_rec, p_ps_rec);

    -- ----------------------------------------------------------------
    -- If best percent is zero, return zero also for earned discount.
    -- (Avoid unnecessary discount fetch in get_current_discount_percent)
    -- ----------------------------------------------------------------
    IF (p_disc_rec.best_disc_pct = 0)
    THEN
      p_disc_rec.earned_disc_pct := 0;
    ELSE       -- used to be ELSIF p_disc_rec.earned_disc_pct IS NULL THEN
      get_current_discount_percent (p_disc_rec, p_ps_rec);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.get_discount_percentages()-');
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug(   'Exception: arp_calculate_discount.'||
			'get_discount_percentages()' );
           END IF;
           RAISE;
END get_discount_percentages;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_payment_schedule_info                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Select Payment Schedule info and populate payment schedule record and  |
 |    two discount record values (calc_disc_on_lines and discount_  |
 |    partial_payment_flag.                                                  |
 | 									     |
 |								             |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                      p_ps_rec - Payment Schedule Record  |
 |									     |
 |		OUT:							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_payment_schedule_info(
    p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
    p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE
     ) IS
l_payment_schedule_id NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.get_payment_schedule_info() +' );
    END IF;
    --
    -- Select Payment Schedule info and populate ps record type and two disc record
    -- values (calc_disc_on_lines and disc_partial_pmt_flag)
    --
    l_payment_schedule_id := p_ps_rec.payment_schedule_id;
    BEGIN
         SELECT ps.term_id,
                ps.terms_sequence_number,
                ps.trx_date,
                ps.amount_due_original,
                ps.amount_due_remaining,
                NVL(ps.discount_taken_earned, 0),
                NVL(ps.discount_taken_unearned, 0),
                NVL(ps.amount_line_items_original, 0),
                ps.invoice_currency_code,
                ps.amount_in_dispute, /*FP Bug 5335376 for Bug 5223829 assign value of dispute*/
                t.calc_discount_on_lines_flag,
                t.partial_discount_flag
         INTO   p_ps_rec.term_id,
                p_ps_rec.terms_sequence_number,
                p_ps_rec.trx_date,
                p_ps_rec.amount_due_original,
                p_ps_rec.amount_due_remaining,
                p_ps_rec.discount_taken_earned,
                p_ps_rec.discount_taken_unearned,
                p_ps_rec.amount_line_items_original,
                p_ps_rec.invoice_currency_code,
                p_ps_rec.amount_in_dispute,/*FP 5335376 for Bug 5223829 assign value of dispute*/
                p_disc_rec.calc_disc_on_lines,
                p_disc_rec.disc_partial_pmt_flag
         FROM   ar_payment_schedules ps, ra_terms t
         WHERE  ps.payment_schedule_id = l_payment_schedule_id
           AND  ps.term_id = t.term_id(+);

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             --error_code := AR_M_NO_RECORD ;
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('get_payment_schedule_info: ' ||  'No data found in ar_payment_schedules' );
                 END IF;
                   RAISE ar_m_no_rec;
             WHEN OTHERS THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('get_payment_schedule_info: ' ||
                       'EXCEPTION: arp_calculate_discount.get_payment_schedule_info' );
                 END IF;
              RAISE;
    END;

    IF ( p_ps_rec.term_id IS NULL ) THEN
         p_ps_rec.term_id := AR_NO_TERM;
    END IF;

    IF ( p_ps_rec.terms_sequence_number IS NULL ) THEN
         p_ps_rec.terms_sequence_number := AR_NO_TERM;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.get_payment_schedule_info()-');
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('get_payment_schedule_info: ' ||  'Exception: arp_calculate_discount.'||
		'get_payment_schedule_info()' );
           END IF;
           RAISE;
END get_payment_schedule_info;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_best_discount_percentage                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Get Best Discount Percentage                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record  |
 |              							     |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 | 29/1/1996	Harri Kaukovuo		Removed IF statements to check whether
 |					returned value is null and replaced
 |					NVL(<value>,0) instead into SELECT.
 +===========================================================================*/
PROCEDURE get_best_discount_percentage(
    p_disc_rec 	IN OUT NOCOPY discount_record_type,
    p_ps_rec 	IN ar_payment_schedules%ROWTYPE
     ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'arp_calculate_discount.'||
		'get_best_discount_percentage()+' );
    END IF;
    --
    -- Get best discount percentage
    --

    SELECT NVL(MAX(discount_percent),0) * 0.01
    INTO   p_disc_rec.best_disc_pct
    FROM   RA_TERMS_LINES_DISCOUNTS tld
    WHERE
	tld.term_id 		= p_ps_rec.term_id
    AND tld.sequence_num 	= p_ps_rec.terms_sequence_number;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   '-- best_discount_percentage:'||
	TO_CHAR( p_disc_rec.best_disc_pct ) );
       arp_standard.debug(   'arp_calculate_discount.'||
	'get_best_discount_percentage()-' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug(   'Exception: arp_calculate_discount.'||
			'get_best_discount_percentage()' );
           END IF;
           RAISE;
END get_best_discount_percentage;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_current_discount_percent                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Get Current Discount Percentage                                        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record  |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |
 |
 | NOTES
 |	Note that this routine has changed from the original and requires
 |	view AR_TRX_DISCOUNTS_V.
 |	This view should be defined in file arvrdisc.sql
 |
 | MODIFICATION HISTORY -
 | 5/24/1995	Created by Shiv Ragunat
 | 1/29/1996	Harri Kaukovuo	Changed routine to use view
 |				AR_TRX_DISCOUNTS_V to centralize
 |				discount calculation.
 | 3/28/1996	H.Kaukovuo	Finished the changes.
 +===========================================================================*/

PROCEDURE get_current_discount_percent(
    p_disc_rec 		IN OUT NOCOPY discount_record_type,
    p_ps_rec 		IN ar_payment_schedules%ROWTYPE
     ) IS

l_terms_sequence_number	NUMBER;
l_term_id 		NUMBER;
l_grace_days 		NUMBER;
l_trx_date 		DATE;
l_apply_date 		DATE;
l_calculated_date	DATE;

-- This cursor will return all possible discounts for selected
-- transaction
CURSOR c_discounts(p_calculated_date in date) IS
	SELECT
		td.discount_percent
	,	td.discount_date
	FROM	ar_trx_discounts_v	td
	WHERE
		td.payment_schedule_id	= p_ps_rec.payment_schedule_id
	AND	p_calculated_date <= td.discount_date
	ORDER BY
	td.discount_date	ASC;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(
	'arp_calculate_discount.get_current_discount_percent()+' );
    END IF;
    --
    -- Get current discount percentage
    --
--7693172
    l_grace_days 		:= NVL(p_disc_rec.grace_days,0);
    l_apply_date 		:= p_disc_rec.apply_date;
    l_calculated_date		:= TRUNC(l_apply_date - l_grace_days);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   '-- l_grace_days := '||TO_CHAR(l_grace_days ));
       arp_standard.debug(   '-- l_apply_date :='||TO_CHAR(l_apply_date,'DD-MON-RRRR HH24:MI:SS' ));
       arp_standard.debug(   '-- l_calculated_date :='||TO_CHAR(l_calculated_date,'DD-MON-RRRR HH24:MI:SS' ));
    END IF;

    -- If cursor does not return anything, this will be the default
    p_disc_rec.earned_disc_pct := 0;

    -- Get the first row, that should be the closest discount date
    FOR rc_discounts IN c_discounts(l_calculated_date) LOOP
        p_disc_rec.earned_disc_pct := rc_discounts.discount_percent*0.01;
        p_disc_rec.out_discount_date := rc_discounts.discount_date;
        EXIT;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  '--p_disc_rec.earned_disc_pct:'||
	TO_CHAR(p_disc_rec.earned_disc_pct));
       arp_standard.debug(   'arp_calculate_discount.'||
	'get_current_discount_percent()-' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'EXCEPTION: arp_calculate_discount.'||
		'get_current_discount_percent()' );
        END IF;
        RAISE;

END get_current_discount_percent;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    correct_lines_only_discounts                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Correct Discount Percentages for LINEs-only discounts.                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record                   |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                         |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |                                                                           |
 |	T Schraid - 7/26/96	Added 2 new discount bases: 'T' and 'F'.     |
 |                              'T' adjusts the discount multiplier to       |
 |                              include amounts on all invoice lines and     |
 |                              their tax.                                   |
 |                              'F' adjusts the discount multiplier to       |
 |                              include amounts on all invoice lines that    |
 |                              are not 'Freight' item and their tax.        |
 |      V Ahluwalia 05/18/98    Bug #592696, if amount due original is 0 then|
 |                              discount percent is 0, prevent division by 0 |
 +===========================================================================*/
PROCEDURE correct_lines_only_discounts(
    p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE ) IS
    l_line_adjusted  NUMBER;
    l_line_applied NUMBER;
    l_amount_adjusted NUMBER;
    l_amount_applied NUMBER;
    l_adjustments BOOLEAN;
    l_credit_memos BOOLEAN;
    l_numerator NUMBER;
    l_denominator NUMBER;
    l_multiplier NUMBER(25,10);
    l_inventory_item_id  NUMBER;
--
--  new variables for the discount bases : 'T' and 'F'
--
    l_tax_original  NUMBER;
    l_tax_adjustments  BOOLEAN;
    l_tax_credit_memos  BOOLEAN;
    l_tax_line_adjusted  NUMBER;
    l_tax_line_applied  NUMBER;
    l_freight_original  NUMBER;

--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.correct_lines_only_discounts() +' );
    END IF;
    --
    --Correct discount percentages for LINEs only discounts.
    --
    l_adjustments := TRUE;
    l_tax_adjustments := TRUE;
    l_credit_memos := TRUE;
    l_tax_credit_memos := TRUE;
    --
    BEGIN
        SELECT nvl(sum(line_adjusted),0), sum(amount), nvl(sum(tax_adjusted),0)
               INTO l_line_adjusted, l_amount_adjusted, l_tax_line_adjusted
               FROM AR_ADJUSTMENTS
              WHERE payment_schedule_id = p_ps_rec.payment_schedule_id
                AND status = 'A';
    END;
    --
    IF ( l_amount_adjusted IS NULL ) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'arp_calculate_discount.correct_lines_only_discounts  : No adjustments for payment schedule' );
        END IF;
        l_adjustments := FALSE;
	l_tax_adjustments := FALSE;
    END IF;
    --
    BEGIN
        SELECT nvl(sum(line_applied),0), sum(amount_applied),
	       nvl(sum(tax_applied),0)
               INTO l_line_applied, l_amount_applied, l_tax_line_applied
               FROM AR_RECEIVABLE_APPLICATIONS
               WHERE application_type = 'CM'
               AND applied_payment_schedule_id = p_ps_rec.payment_schedule_id
               AND status = 'APP'
               AND application_rule in ('65','66','67');
    END;
    --
    IF ( l_amount_applied IS NULL ) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'arp_calculate_discount.correct_lines_only_discounts  : No credit memos for payment schedule' );
        END IF;
        l_credit_memos := FALSE;
        l_tax_credit_memos := FALSE;
    END IF;

    --set numerator = LINES_ORIGINAL + sum(LINE_ADJUSTED) - sum(RA LINE CM)
    --and the denominator = ADO + sum(AMOUNT_ADJUSTED) - sum(RA CM)  */

    -- If discount basis = 'F' then get amounts on non-freight item lines,
    -- i.e. lines where the inventory item id is not the same as the one
    -- defined in profile option Tax: Inventory Item for Freight.

    IF (p_disc_rec.calc_disc_on_lines IN ('L','F'))
    THEN

    -- OE/OM change
      fnd_profile.get('ZX_INVENTORY_ITEM_FOR_FREIGHT', l_inventory_item_id);


      IF l_inventory_item_id IS NOT NULL  THEN

        BEGIN

          /* 7659455 - We now calculate numerator for both L and F here.
             L is line-only so line_type must = LINE.
             F is both line and tax, so we sum all returned rows.

             Freight rows are always excluded (by where clause)

              IF line_type = LINE,
                 return extended_amount
              ELSE
                 IF calc_disc_on_lines = F (Lines + Tax, not Freight + Tax)
                    return extended_amount
                 ELSE
                    return zero (for this line)
                 END IF
              END IF
          */

	  SELECT nvl(sum(
                 DECODE(rctl.line_type, 'LINE', rctl.extended_amount,
                          DECODE(p_disc_rec.calc_disc_on_lines, 'F',
                                    rctl.extended_amount, 0))),0)
	  INTO   l_numerator
          FROM
             ra_customer_trx_lines rctl,
             ar_payment_schedules ps
          WHERE
                rctl.line_type IN ('LINE','TAX')
          AND   nvl(rctl.inventory_item_id,-1) <> l_inventory_item_id
          AND   nvl(rctl.link_to_cust_trx_line_id,-1)
          NOT IN (
                SELECT  rctl2.customer_trx_line_id
                FROM
                        ra_customer_trx_lines  rctl2,
                        ar_payment_schedules  ps2
                WHERE
                        nvl(rctl2.inventory_item_id,-1) = l_inventory_item_id
                AND     rctl2.customer_trx_id = ps2.customer_trx_id
                AND     ps2.payment_schedule_id = p_ps_rec.payment_schedule_id
                )
          AND   rctl.customer_trx_id = ps.customer_trx_id
          AND   ps.payment_schedule_id = p_ps_rec.payment_schedule_id;

        END;

      ELSE

    -- As inventory item id = null, discount basis = 'F' makes no sense;
    -- Set discount basis = 'T'

	-- Bug 8298719
	IF p_disc_rec.calc_disc_on_lines <> 'L' THEN
	       p_disc_rec.calc_disc_on_lines := 'T';
	END IF;
	l_numerator := p_ps_rec.amount_line_items_original;

      END IF;

      l_denominator := p_ps_rec.amount_due_original;

    ELSE -- calc_disc_on_lines IN T,Y (and I?)

      l_numerator := p_ps_rec.amount_line_items_original;
      l_denominator := p_ps_rec.amount_due_original;

    END IF;
    -- If discount basis = 'T' then get the tax amounts.

    IF (p_disc_rec.calc_disc_on_lines = 'T') THEN

      BEGIN
    	SELECT nvl(tax_original,0)
	INTO   l_tax_original
	FROM   ar_payment_schedules
	WHERE  payment_schedule_id = p_ps_rec.payment_schedule_id;
      END;
    --
    -- Added for bug 657409.
       BEGIN
         SELECT nvl(freight_original,0)
         INTO   l_freight_original
         FROM   ar_payment_schedules
         WHERE  payment_schedule_id = p_ps_rec.payment_schedule_id;
       END;

        l_numerator := l_numerator + l_tax_original + l_freight_original;
    --
    END IF;
    --
    IF (l_adjustments) THEN
        l_numerator := l_numerator + l_line_adjusted;
        l_denominator := l_denominator + l_amount_adjusted;
    END IF;
    --
    IF (l_credit_memos) THEN
        l_numerator := l_numerator - l_line_applied;
        l_denominator := l_denominator - l_amount_applied;
    END IF;
    --
    IF (l_tax_adjustments) AND (p_disc_rec.calc_disc_on_lines = 'T') OR
       (l_tax_adjustments) AND (p_disc_rec.calc_disc_on_lines = 'F') THEN
        l_numerator := l_numerator + l_tax_line_adjusted;
    END IF;
    --
    IF (l_tax_credit_memos) AND (p_disc_rec.calc_disc_on_lines = 'T') OR
       (l_tax_credit_memos) AND (p_disc_rec.calc_disc_on_lines = 'F')  THEN
        l_numerator := l_numerator - l_tax_line_applied;
    END IF;
    --
    p_disc_rec.adjusted_ado := l_denominator;

    -- Bug 592696 if amount due original is 0 then discount is 0
    -- prevent division by 0.

    IF l_denominator = 0 THEN
       l_multiplier := 0;
    ELSE
       l_multiplier := l_numerator / l_denominator;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   '  l_multiplier:'||TO_CHAR(l_multiplier));
    END IF;
    p_disc_rec.earned_disc_pct := p_disc_rec.earned_disc_pct * l_multiplier;
    p_disc_rec.best_disc_pct :=  p_disc_rec.best_disc_pct * l_multiplier;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   '  p_disc_rec.adjusted_ado:'||TO_CHAR(p_disc_rec.adjusted_ado));
       arp_standard.debug(   '  p_disc_rec.earned_disc_pct:'||TO_CHAR(p_disc_rec.earned_disc_pct));
       arp_standard.debug(   '  p_disc_rec.best_disc_pct:'||TO_CHAR(p_disc_rec.best_disc_pct));
       arp_standard.debug( 'arp_calculate_discount.correct_lines_only_discounts() -' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug( 'Exception: arp_calculate_discount.correct_lines_only_discounts()' );
           END IF;
           RAISE;
END correct_lines_only_discounts;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    decrease_discounts_to_adr                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Decrease Discounts so ADR(Amount Due Remaining) is not exceeded.       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record  |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                      p_earned_discount - Earned Discount                  |
 |                      p_unearned_discount - Unearned Discount              |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE decrease_discounts_to_adr(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER) IS
    l_amt_due_remaining NUMBER;
    l_amt NUMBER;
    l_new_amt_due_remaining NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.decrease_discounts_to_adr() +' );
    END IF;
    --
    l_amt_due_remaining := p_ps_rec.amount_due_remaining;
    l_amt := p_disc_rec.input_amt;
    -- Subtract payment amount from ADR.
    l_new_amt_due_remaining := l_amt_due_remaining -
                          l_amt;
    -- If the input amount exceeded the input ADR, then the sign
    -- of the difference will not be the same as the input ADR. If
    -- this is the case, set discounts to zero and exit.
    IF ( ( l_amt_due_remaining > 0 AND l_new_amt_due_remaining < 0 ) OR (l_amt_due_remaining < 0 AND l_new_amt_due_remaining > 0)) THEN
    	 p_earned_disc := 0;
    	 p_unearned_disc := 0;
        RETURN;
    END IF;
    --
    --If taking the full earned discount will overpay the payment
    --schedule, set earned discount = remaining amount, set unearned
    --discount to zero, and exit.
    IF ( ( l_amt_due_remaining > 0 AND p_earned_disc > l_new_amt_due_remaining ) OR ( l_amt_due_remaining < 0 AND p_earned_disc < l_new_amt_due_remaining ) ) THEN
         p_earned_disc := l_new_amt_due_remaining ;
         p_unearned_disc := 0;
    RETURN;
    END IF;
    --
    -- Subtract earned discount from ADR.
    l_new_amt_due_remaining := l_new_amt_due_remaining - p_earned_disc;
    -- If taking the full unearned discount will overpay the payment
    -- schedule, set unearned discount = remaining amount.
    IF ( ( l_amt_due_remaining > 0 AND p_unearned_disc > l_new_amt_due_remaining ) OR ( l_amt_due_remaining < 0 AND p_unearned_disc < l_new_amt_due_remaining ) )  THEN
--         p_unearned_disc := l_amt_due_remaining;
         p_unearned_disc := l_new_amt_due_remaining;
        RETURN;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.decrease_discounts_to_adr() +' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug( 'Exception: arp_calculate_discount.decrease_discounts_to_adr()');
           END IF;
           RAISE;
END decrease_discounts_to_adr;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    determine_max_allowed_disc                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determine Maximum Allowable Discount                                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_mode,  p_ps_rec - Payment Schedule Record  |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE determine_max_allowed_disc(
    p_mode IN NUMBER,
    p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE ) IS
    l_amount_adjusted NUMBER;
    l_amount_applied NUMBER;
    l_adjustments BOOLEAN;
    l_credit_memos BOOLEAN;
    l_max_allowed_discount NUMBER;
    l_amt_due_original NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.determine_max_allowed_disc() +' );
    END IF;
    --
    l_adjustments := TRUE;
    l_credit_memos := TRUE;
    --
    --Get adjusted ADO. This is ADO + sum(AMOUNT_ADJUSTED) -
    -- sum(RA CREDITED). If calc_disc_on_lines = 'Y', then this
    -- value has already been computed and stored in adjusted_ado
    -- of the disc_struct record type. Otherwise, select from the
    -- database.
    IF ( p_disc_rec.adjusted_ado IS NULL ) THEN
    --  /*=========================================+
    --    Need to select and calculate adjusted ADO
    --   +=========================================*/
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  'Selecting from database ' );
        END IF;
        BEGIN
              SELECT sum(amount)
              INTO l_amount_adjusted
              FROM AR_ADJUSTMENTS
              WHERE payment_schedule_id = p_ps_rec.payment_schedule_id
              AND status = 'A';
        END;
        --
        IF ( l_amount_adjusted IS NULL ) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(  'No adjustments for payment schedule' );
            END IF;
            l_adjustments := FALSE;
        END IF;
        --
        BEGIN
            SELECT sum(amount_applied)
            INTO l_amount_applied
            FROM AR_RECEIVABLE_APPLICATIONS
            WHERE application_type = 'CM'
            AND applied_payment_schedule_id = p_ps_rec.payment_schedule_id
            AND status = 'APP'
            AND application_rule in ('65','66','67','75');
        END;
        --
        IF ( l_amount_applied IS NULL ) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(  'No credit memos for payment schedule' );
            END IF;
            l_credit_memos := FALSE;
        END IF;
        --
        l_amt_due_original := p_ps_rec.amount_due_original;
    ---
    ---
        IF (l_adjustments) THEN
            l_amt_due_original := l_amt_due_original + l_amount_adjusted;
        END IF;
        --
        IF (l_credit_memos) THEN
           l_amt_due_original := l_amt_due_original - l_amount_applied;
        END IF;
        --
        IF ( NOT l_adjustments AND NOT l_credit_memos) THEN
           p_disc_rec.adjusted_ado := p_ps_rec.amount_due_original;
        ELSE
           p_disc_rec.adjusted_ado := l_amt_due_original;
        END IF;
        --
---
---
    ELSE
    --  =========================================+
    --    Adjusted ADO already stored.
    --  =========================================
        l_amt_due_original := p_disc_rec.adjusted_ado;
    END IF;
---
---
    --
    -- Get max allowed total discount.
    -- multiply best percentage by adjusted ADO  to get max total discount
    IF (p_mode = AR_DIRECT_NEW_DISC OR p_mode = AR_DEFAULT_NEW_DISC) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'Default or Direct Mode p_mode=' || to_char(p_mode));
        END IF;
        l_max_allowed_discount :=  p_disc_rec.best_disc_pct *
                                   p_disc_rec.adjusted_ado;
                            -- Modified for RT Bug Feb 28, 97.
                                   -- p_ps_rec.amount_due_original;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'Not in Default/Direct Mode p_mode=' || to_char(p_mode));
        END IF;
        l_max_allowed_discount :=  p_disc_rec.best_disc_pct *
                                   l_amt_due_original;
    END IF;
    --
    -- Added Logic for Rounding Nov 12, 96:  Bug #408762
    --
       l_max_allowed_discount :=
          arpcurr.CurrRound(l_max_allowed_discount,  p_ps_rec.invoice_currency_code);
    --
    --
    -- Subtract discounts already taken from max total discount.
    l_max_allowed_discount := l_max_allowed_discount -
                              p_ps_rec.discount_taken_earned -
                              p_ps_rec.discount_taken_unearned;
    --
    -- If the discount taken exceeds the max total discount,set
    --   max allowable discount to zero and exit.
    --
    -- BUG 3497682
    IF ( (l_max_allowed_discount < 0 and l_amt_due_original > 0) or
         (l_max_allowed_discount > 0 and l_amt_due_original < 0 )) THEN
        p_disc_rec.max_disc := 0;
        RETURN;
    END IF;
    --
    -- Populate max allowable discount and exit.
    --
    p_disc_rec.max_disc := l_max_allowed_discount;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.determine_max_allowed_disc() -' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug( 'Exception: arp_calculate_discount.determine_max_allowed_disc()');
           END IF;
           RAISE;
END determine_max_allowed_disc;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calculate_direct_discount                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Calculate Direct Discount                                    |
 |								             |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record  |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                      p_earned_discount - Earned Discount                  |
 |                      p_unearned_discount - Unearned Discount              |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |  03/30/00   R Yeluri           Added rounding logic to calculate    |
 |                                earned and unearned discounts by     |
 |                                maintaining previous totals. Bug fix |
 |                                910516                               |
 |  04/25/02   S.Nambiar          Bug 2334691 - If the discount on partial
 |                                payment flag is 'Y' in system option, then
 |                                check the partial payment flag on payment
 |                                term,and take the flag from payment term. But
 |                                if the flag is 'N' in system option, then
 |                                no matter what payment term flag says,partial
 |                                discounts should not be allowed.
 |                                                                           |
 +===========================================================================*/
PROCEDURE calculate_direct_discount(
    p_mode IN NUMBER,
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER,
    p_called_from IN VARCHAR2 DEFAULT 'AR') IS
    l_ado NUMBER;
    l_earned_disc_pct NUMBER;
    l_best_pct NUMBER;
    l_input_amt NUMBER;
    l_amt_due_remaining NUMBER;
    l_best_disc NUMBER;
    l_temp NUMBER;

    -- Added the following variables to fix bug 910516
    l_amount_applied_to NUMBER;
    l_earned_discount_taken NUMBER ;
    l_unearned_discount_taken NUMBER ;
    l_input_amt_earned NUMBER;
    l_input_amt_unearned NUMBER;
    l_discount_remaining NUMBER ;
    l_sys_disc_partial_pay_flag  VARCHAR2(1) := 'N' ;
    l_ps_disc_partial_pay_flag  VARCHAR2(1) := 'N' ;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.calculate_direct_discount() +' );
    END IF;
    --
    l_ado := p_disc_rec.adjusted_ado;
    l_earned_disc_pct := p_disc_rec.earned_disc_pct;
    l_best_pct := p_disc_rec.best_disc_pct;
    l_input_amt := p_disc_rec.input_amt;
    l_ps_disc_partial_pay_flag := p_disc_rec.disc_partial_pmt_flag;


    -- Added here by Ketul Nov 18, 96 for Bug #423908
    l_amt_due_remaining := p_ps_rec.amount_due_remaining;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   '  l_earned_disc_pct:'||TO_CHAR(l_earned_disc_pct));
       arp_standard.debug(   '  l_best_pct:'||TO_CHAR(l_best_pct));
       arp_standard.debug(   '  l_input_amt:'||TO_CHAR(l_input_amt));
    END IF;
    --Methods for calculating discounts depend on whether or not
    --discounts are allowed on partial payments.

    -- Initialized the following to fix bug 910516
    l_input_amt_earned := 0;
    l_input_amt_unearned := 0;
    l_amount_applied_to := 0;
    l_earned_discount_taken := 0;
    l_unearned_discount_taken := 0;

    SELECT arp_standard.sysparm.partial_discount_flag
    INTO l_sys_disc_partial_pay_flag
    FROM dual;

   /*--------------------------------------------------------------------+
    |Bug 2334691 - If partial discount flag in system option is 'N' then |
    |l_disc_rec.disc_partial_pmt_flag= 'N' , if discount flag is 'Y' on  |
    |system option, then take the value from payment terms record        |
    *--------------------------------------------------------------------*/

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Partial Discount flag System Options = '|| l_sys_disc_partial_pay_flag);
       arp_standard.debug(   'Partial Discount flag Payment Term = '|| l_ps_disc_partial_pay_flag);
    END IF;

    IF NVL(l_sys_disc_partial_pay_flag,'N') = 'N' THEN
           l_ps_disc_partial_pay_flag := 'N';
    ELSE
           null;
    END IF;


    IF  NVL(l_ps_disc_partial_pay_flag,'N') = 'Y'
    THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  '  disc_partial_pmt_flag: Y' );
        END IF;
        --
        --If partial payment discount is allowed then the following steps
        --are done.
        --When earned discount % = 100%, discount = ADR.

        -- Added by to fix bug 910516.
        -- This will enable to maintain running totals for amount_applied,
        -- earned_discount and unearned_discount, to eliminate rounding
        -- errors during calculation of earned and unearned discounts

        begin
	/*For bug 2448636 to populate l_input_amt correctly
	   retrieved sum(amount_applied) instead of sum(line_applied)*/
                select  nvl(sum(amount_applied),0),
                        nvl(sum(earned_discount_taken),0),
                        nvl(sum(unearned_discount_taken),0)
                into    l_amount_applied_to, l_earned_discount_taken,
                        l_unearned_discount_taken
                from    ar_receivable_applications
                where   applied_payment_schedule_id =
                                        p_ps_rec.payment_schedule_id
                and     application_type = 'CASH'
                and     status = 'APP';

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug(  'from ar_rec_app :');
             arp_standard.debug(  'payment_schedule_id = ' || to_char(p_ps_rec.payment_schedule_id));
             arp_standard.debug(  'l_amount_applied_to = ' || to_char(l_amount_applied_to));
             arp_standard.debug(  'l_earned_discount_taken = ' || to_char(l_earned_discount_taken));
             arp_standard.debug(  'l_unearned_discount_taken = ' || to_char(l_unearned_discount_taken));
          END IF;
        end;

        IF l_earned_disc_pct = 1
        THEN
            p_earned_disc := p_ps_rec.amount_due_remaining;
        ELSE
            --  calculate earned discount
            --  If adr - (adr)*(disc%) < payment amount, earned discount = (adr)*(disc%)
            --

            l_amt_due_remaining := p_ps_rec.amount_due_remaining;
            l_temp := l_amt_due_remaining
	            - arpcurr.CurrRound(l_amt_due_remaining*l_earned_disc_pct,
		                        p_ps_rec.invoice_currency_code);

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(  'l_temp = ' || to_char(l_temp));
            END IF;

            IF ( ( l_amt_due_remaining > 0 AND l_temp <= l_input_amt ) OR
              ( l_amt_due_remaining < 0 AND l_temp >= l_input_amt ) )
            THEN
                p_earned_disc := l_amt_due_remaining * l_earned_disc_pct;
            ELSE
                /*-----------------------------------------------------
                Bug fix 910516
                Add any previous applications to the current input amt
                and calculate the earned discount on the sum. Later the
                correct earned discount is got by subtracting the discount
                taken from the earned discount.

                Bug 2598297 :
                adding back previous amount applications into l_input_amt_earned
                and then using this amount to compute discount based on *current*
                discount rate is incorrect, because the discount rate may have
                been different for previous applications.

                Instead, compute discount earned for current receipt only
                and then later add back all discount amounts taken
                --------------------------------------------------------*/

                -- replace following line :
                -- l_input_amt_earned := l_input_amt + l_amount_applied_to;
                -- with :

                l_input_amt_earned := l_input_amt;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug(
                                      'current receipt amount : l_input_amt_earned --:' ||
                                      TO_CHAR(l_input_amt_earned));
                END IF;

                /*------------------------------------------------------------

                adr - (adr)*(disc%) >= payment amount

                earned discount = (payment amount) * (discount %)
                                  ---------------------------------
                                          1 - (discount %)
                --------------------------------------------------------------*/

                -- discount for the current receipt application
                p_earned_disc := (l_input_amt_earned * l_earned_disc_pct) /
                                 ( 1 - l_earned_disc_pct );

                -- Bug 2716569 : took out extraneous code that was adding and then later subtracting
                -- l_earned_discount_taken from p_earned_disc
                -- also consolidated debug messages in one if pg_debug if block

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug(
                                      'discount available for THIS receipt : ' ||
                                      to_char(p_earned_disc));

                   arp_standard.debug('calculate_direct_discount: total redeemable discount 1 : ' ||
                                      TO_CHAR(p_earned_disc + l_earned_discount_taken));
                END IF;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   'total redeemable discount 3 :'||TO_CHAR(p_earned_disc));
            END IF;

        END IF;
        --
        -- Calculate unearned discount.
        -- unearned discount = ((best %) * (input amount)) - (earned
        -- discount)
        -- If current percent equals best percent, unearned discount =0.
        --
        IF l_earned_disc_pct = l_best_pct
        THEN
            p_unearned_disc := 0;
        ELSE
            -- Get best discount
            --
            -- check special case: 100% discount
            IF l_earned_disc_pct = 1
            THEN
                l_best_disc := p_ps_rec.amount_due_remaining;
            ELSE
                -- If discount is 100%, best dicount = ADR, otherwise
                -- If adr - (adr)*(disc%) < payment amount, then best discount =
                -- (adr)*(disc%)
                --
                l_temp := l_amt_due_remaining - l_amt_due_remaining*l_best_pct;
                IF ( ( l_amt_due_remaining > 0 AND l_temp < l_input_amt ) OR
                   ( l_amt_due_remaining < 0 AND l_temp > l_input_amt ) ) THEN
                    l_best_disc := l_amt_due_remaining*l_best_pct;
                ELSE
                    -- added for bugfix 910516
                 l_input_amt_unearned := l_input_amt + l_amount_applied_to;

                    -- Otherwise best discount = (payment amount * best %)
                    --                            -------------------------
                    --                             1- best %
                  -- Added the condition to fix bug 1236196
                  IF l_best_pct <> 1 THEN
                    l_best_disc := (l_input_amt_unearned*l_best_pct ) /
                                                ( 1 - l_best_pct );
                  END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(  'ptr 1- l_unearned_disc:'||TO_CHAR(l_best_disc));
            END IF;
                l_best_disc := l_best_disc - l_unearned_discount_taken;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(  'ptr 2- l_unearned_disc:'||TO_CHAR(l_best_disc));
            END IF;
                END IF;
            END IF;
            --
            -- Subtract earned discount from best discount to get unearned
            -- discount.
            p_unearned_disc := l_best_disc - p_earned_disc;
        END IF;
    --
    ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(  '  disc_partial_pmt_flag: !Y' );
         END IF;
         -- If partial payment discount is not allowed, then the following
         -- steps are taken.
         -- earned discount = (current %) * ADO
         p_earned_disc := l_earned_disc_pct * l_ado;
         --
         -- and unearned discount = (best% * ADO) - (earned discount)
         p_unearned_disc := (l_best_pct * l_ado ) - p_earned_disc;
         --
    END IF;
    --
    -- Added Logic for Rounding Nov 12, 96:  Bug #408762
    --
       p_earned_disc :=
           arpcurr.CurrRound(p_earned_disc,  p_ps_rec.invoice_currency_code);
       p_unearned_disc :=
           arpcurr.CurrRound(p_unearned_disc,  p_ps_rec.invoice_currency_code);
    --
    -- make sure max discount is not exceeded. reduce discounts as needed
    --
    IF NVL(l_ps_disc_partial_pay_flag,'N') = 'N'
    THEN
        -- If (input amount + discount to take) < ADR , then
        -- Set discount to 0.
        --
        IF p_disc_rec.earned_both_flag = 'B'
        THEN
            l_temp := l_input_amt + p_earned_disc + p_unearned_disc;
        ELSE
            l_temp := l_input_amt + p_earned_disc;
        END IF;
        --
        /* bug 3497682:  */
/*FP Bug 5335376 for Bug  5223829 Leftover changes of bug for case of system option partial discount unchecked
  Modify the check condition to include dispute amount based on parameter p_called_from*/

        IF p_called_from = 'OIR' THEN
          IF ( (l_temp < (l_amt_due_remaining + nvl(p_ps_rec.amount_in_dispute,0))and
                p_ps_rec.amount_due_original >= 0) or
               (l_temp > (l_amt_due_remaining + nvl(p_ps_rec.amount_in_dispute,0)) and
                p_ps_rec.amount_due_original < 0))
          THEN
              p_earned_disc := 0;
              p_unearned_disc := 0;
          END IF;
        ELSE

          IF ( (l_temp < l_amt_due_remaining and
              p_ps_rec.amount_due_original >= 0) or
             (l_temp > l_amt_due_remaining and
              p_ps_rec.amount_due_original < 0))
          THEN
            p_earned_disc := 0;
            p_unearned_disc := 0;
          END IF;
        END IF;
    END IF;

    IF p_mode = AR_DIRECT_NEW_DISC OR p_mode = AR_DEFAULT_NEW_DISC
    THEN
        p_unearned_disc := p_disc_rec.max_disc - p_earned_disc;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   '-- p_earned_disc: '||TO_CHAR(p_earned_disc));
       arp_standard.debug(   '-- max_disc:' ||TO_CHAR(p_disc_rec.max_disc));
       arp_standard.debug(   '-- p_unearned_disc:'||TO_CHAR(p_unearned_disc));
       arp_standard.debug( 'arp_calculate_discount.calculate_direct_discount()-');
   END IF;

    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug(   'Exception: arp_calculate_discount.'||
			'calculate_direct_discount()');
           END IF;
           RAISE;
END calculate_direct_discount;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calculate_default_discount                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Calculate Default Discount                                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record  |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                      p_earned_discount - Earned Discount                  |
 |                      p_unearned_discount - Unearned Discount              |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |                                                                           |
 +===========================================================================*/
--
PROCEDURE calculate_default_discount(
    p_mode IN NUMBER,
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER,
    p_out_amt_to_apply IN OUT NOCOPY NUMBER,
    p_called_from IN VARCHAR2 DEFAULT 'AR') IS
    l_ado NUMBER;
    l_earned_disc_pct NUMBER;
    l_best_pct NUMBER;
    l_input_amt NUMBER;
    l_amt_due_remaining NUMBER;
    l_best_disc NUMBER;
    l_temp NUMBER;
    l_disc_to_take NUMBER;
    l_OIR_AR  BOOLEAN;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.calculate_default_discount() +' );
    END IF;
    --
/*FP bug 5335376 for Bug 5223829 Leftover changes of bug for case of system option partial discount unchecked
  Set variable based on parameter p_called_from*/

    l_OIR_AR := FALSE;

    l_ado := p_disc_rec.adjusted_ado;
    l_earned_disc_pct := p_disc_rec.earned_disc_pct;
    l_best_pct := p_disc_rec.best_disc_pct;
    l_input_amt := p_disc_rec.input_amt;
    l_amt_due_remaining := p_ps_rec.amount_due_remaining;
    --
    --Methods for calculating discounts depend on whether or not
    --discounts are allowed on partial payments.
    IF ( p_disc_rec.disc_partial_pmt_flag = 'Y') THEN
       --
       --If partial payment discount is allowed then the following steps
       --are done.
       --Earned discount = ADR * (earned discount %)
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(   'l_amt_due_remaining = '||TO_CHAR( l_amt_due_remaining ));
   arp_standard.debug(   'l_earned_disc_pct = '||TO_CHAR( l_earned_disc_pct ));
END IF;
       p_earned_disc := l_amt_due_remaining * l_earned_disc_pct;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(   'p_earned_disc = '||TO_CHAR( p_earned_disc ));
END IF;
       --Calculate unearned discount.
       --If earned discount percentage equal to best discount percentage.
       --unearned discount = 0.
       IF ( l_earned_disc_pct = l_best_pct ) THEN
          p_unearned_disc := 0;
          --Otherwise
          --Best discount = ADR * best discount %
       ELSE
          l_best_disc := l_amt_due_remaining * l_best_pct;
          --Subtract earned from best to get unearned discount
          p_unearned_disc := l_best_disc - p_earned_disc ;
       END IF;
    ELSE
       --If partial payment discount is not allowed, then the following
       --steps are taken.
       --Earned discount = ADO * (earned discount %)
       p_earned_disc := l_ado * l_earned_disc_pct;
       -- calculate unearned discount
       --If earned discount percentage equals best discount percentage
       --Unearned discount = 0.
       IF ( l_earned_disc_pct = l_best_pct ) THEN
          p_unearned_disc := 0;
       --Otherwise
       --best discount = ADO * best discount%
       ELSE
          l_best_disc := l_ado * l_best_pct;
          --Subtract earned from best to get unearned
          p_unearned_disc := l_best_disc - p_earned_disc ;
       END IF;
    END IF;
   --
    -- Added logic for rounding: Nov 12, 96  Bug #408762
       p_earned_disc :=
         arpcurr.CurrRound(p_earned_disc,  p_ps_rec.invoice_currency_code);
       p_unearned_disc :=
         arpcurr.CurrRound(p_unearned_disc,  p_ps_rec.invoice_currency_code);
    --
    --
    -- make sure max discount is not exceeded. reduce discounts as needed
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'before decrease_discounts_to_maxd, p_earned_disc = '||TO_CHAR( p_earned_disc ) );
       arp_standard.debug(   'before decrease_discounts_to_maxd, p_unearned_disc = '||TO_CHAR( p_unearned_disc ) );
       arp_standard.debug(   'before decrease_discounts_to_maxd, p_disc_rec.max_disc = '||TO_CHAR( p_disc_rec.max_disc ) );
    END IF;
--
--    arp_standard.debug( '   TEST: do not call decrease_discounts_to_maxd');
  decrease_discounts_to_maxd(p_disc_rec, p_ps_rec, p_earned_disc, p_unearned_disc );
--
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'After decrease_discounts_to_maxd, p_earned_disc = '||TO_CHAR( p_earned_disc ) );
       arp_standard.debug(   'After decrease_discounts_to_maxd, p_unearned_disc = '||TO_CHAR( p_unearned_disc ) );
       arp_standard.debug(   'After decrease_discounts_to_maxd, p_disc_rec.max_disc = '||TO_CHAR( p_disc_rec.max_disc ) );
    END IF;
--
    -- amount to apply = ADR - discount to be taken
    -- calculate discount to take
    --If earned both flag = 'Y'
    --discount to take = earned discount + unearned discount
    IF ( p_disc_rec.earned_both_flag = 'B') THEN
       l_disc_to_take := p_earned_disc + p_unearned_disc ;
    --Otherwise
    ELSE
       --Discount to take = Earned discount
       l_disc_to_take := p_earned_disc;
    END IF;
    -- subtract discount from ADR
    p_out_amt_to_apply := l_amt_due_remaining - l_disc_to_take;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(   'p_out_amt_to_apply = '||TO_CHAR( p_out_amt_to_apply ));
   arp_standard.debug(   'l_amt_due_remaining = '||TO_CHAR( l_amt_due_remaining ));
   arp_standard.debug(   'l_disc_to_take = '||TO_CHAR( l_disc_to_take ));
END IF;
    --If Input Amount = CLOSE_INVOICE then
    IF ( p_disc_rec.close_invoice_flag = 'Y' ) THEN
       RETURN;
    END IF;
    --Exit succesfully
    --If Profile:Default Amount Applied = Unapplied amount of payment('PMT')
    --Then
    IF ( p_disc_rec.default_amt_app = 'PMT' ) THEN
        --If balance due (amount to apply) < 0
        --then exit, else
        IF ( p_out_amt_to_apply  >= 0 ) THEN
/* bug 3766518: we do not want to zero out the amounts */
--           IF (l_input_amt < 0 ) THEN
--              p_out_amt_to_apply := 0;
--              p_earned_disc := 0;
--              p_unearned_disc := 0;
--           ELSE
/*FP bug 5335376 for Bug 5223829 Leftover changes of bug for case of system option partial discount unchecked
  Set variable based on  parameter p_called_from and conditional check as per discount calc*/
              IF p_called_from = 'OIR' then
                IF ( l_input_amt < (p_out_amt_to_apply + nvl(p_ps_rec.amount_in_dispute,0))) THEN
                   l_OIR_AR := TRUE;
                END IF;
              ELSE
                IF ( l_input_amt < p_out_amt_to_apply ) THEN
                   l_OIR_AR := TRUE;
                END IF;
              END IF;

             IF l_OIR_AR THEN
                   p_out_amt_to_apply := l_input_amt;
                   IF PG_DEBUG in ('Y', 'C') THEN
                      arp_standard.debug(   'p_out_amt_to_apply = '||TO_CHAR( p_out_amt_to_apply ));
                   END IF;

                IF ( p_disc_rec.disc_partial_pmt_flag = 'N' ) THEN
                    p_earned_disc := 0;
                    p_unearned_disc := 0;
                ELSE
/*FP bug 5335376 for Bug 5223829 Call based on the parameter p_called_from*/
                    calculate_direct_discount( p_mode, p_disc_rec, p_ps_rec,
                         p_earned_disc, p_unearned_disc,p_called_from );
                    /*FP Bug- 5741063 Base Bug 5386459 Call procedure to reduce default discount to max availabel discount*/
                    decrease_discounts_to_maxd(p_disc_rec, p_ps_rec, p_earned_disc, p_unearned_disc );
                END IF;
              END IF;
--           END IF;
        ELSE     /* BUG 3497682: p_amt_to_apply is negative */
/* bug 3766518: we do not want to zero out the amounts */
--            IF (l_input_amt > 0)  then
--               p_out_amt_to_apply := 0;
--               p_earned_disc := 0;
--               p_unearned_disc := 0;
--            ELSE
               if (l_input_amt > p_out_amt_to_apply) then
                  p_out_amt_to_apply := l_input_amt;
                  IF ( p_disc_rec.disc_partial_pmt_flag = 'N' ) THEN
                    p_earned_disc := 0;
                    p_unearned_disc := 0;
                   ELSE
/*FP 5335376for Bug 5223829 Call based on the parameter p_called_from*/
                     calculate_direct_discount( p_mode, p_disc_rec, p_ps_rec,
                         p_earned_disc, p_unearned_disc,p_called_from );
                   /*FP Bug 5741063 Base Bug 5386459 Call procedure to reduce default discount to max availabel discount*/
                    decrease_discounts_to_maxd(p_disc_rec, p_ps_rec, p_earned_disc, p_unearned_disc );
                   END IF;
               end if;
            END IF;
--        END IF;
    END IF;
    --
    --
    --
    IF (p_mode = AR_DIRECT_NEW_DISC OR p_mode = AR_DEFAULT_NEW_DISC) THEN
        p_unearned_disc := p_disc_rec.max_disc - p_earned_disc;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'p_earned_disc in calculate_default_discount = '||
                        TO_CHAR( p_earned_disc ) );
       arp_standard.debug( 'max_disc in calculate_default_discount = '||
                        TO_CHAR( p_disc_rec.max_disc ) );
       arp_standard.debug( 'p_unearned_disc in calculate_default_discount = '||
                        TO_CHAR( p_unearned_disc ) );
    END IF;
    --
    --
    --
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(   'p_earned_disc = '||TO_CHAR( p_earned_disc ));
   arp_standard.debug(   'p_out_amt_to_apply = '||TO_CHAR( p_out_amt_to_apply ));
END IF;
    --If receipt unapplied (input amount) < 0
    --then Amount to default(amount to apply) =0.
    --else
    --If receipt unapplied(input amount) >= balance due(amount to apply)
    --exit
    --else
    --If discounts on partial payments allowed
    --then
    --call ardcdir to calculate discount
    --else
    --set discount to 0.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.calculate_default_discount() -' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug( 'Exception: arp_calculate_discount.calculate_default_discount()');
           END IF;
           RAISE;
END calculate_default_discount;
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_input                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Check if the all the needed fields of the discount record and the      |
 |    payment schedule record are populated, If not exit with error. Also    |
 |    the select flag is checked and if not valid then error is returned.    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_disc_rec - Discount Record                         |
 |                      p_select_flag - Select Flag			     |
 | 									     |
 |              IN OUT:							     |
 |                      p_ps_rec - Payment Schedule Record                   |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : TRUE / FALSE                                                 |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat  - 05/25/95                |
 |                                                                           |
 |	T Schraid - 07/26/96	Modified to allow new discount bases:        |
 |                              'I', 'L', 'T', 'F'.  Retained original       |
 |                              values of 'Y' and 'N'.			     |
 +===========================================================================*/
PROCEDURE check_input(
    p_disc_rec IN  discount_record_type,
    p_select_flag     IN BOOLEAN,
    p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.check_input() +' );
    END IF;
    --
    -- If Input Amount equals NULL
    -- exit with error
    IF  p_disc_rec.input_amt IS NULL
    THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'arp_calculate_discount.check_input : Input amount is NULL. Must have a value.' );
        END IF;
        --error_code := AR_M_FAILURE ;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'Check input Failed' );
        END IF;
        --APP_EXCEPTION.raise_exception;
        RAISE ar_m_fail;
    END IF;
    -- If apply date = NULL
    -- exit with error
    IF p_disc_rec.apply_date IS NULL
    THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'arp_calculate_discount.check_input : Apply date is NULL. Must have a value.' );
        END IF;
        --error_code := AR_M_FAILURE ;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(   'Check input Failed' );
        END IF;
        --APP_EXCEPTION.raise_exception;
        RAISE ar_m_fail;
    END IF;
    -- If Select flag = FALSE
    -- If term_id >= 0 and term_sequence_number >=0
    -- If disc_partial_payment_flag <> 'Y' and <> 'N'
    -- Exit with error
    IF p_select_flag = FALSE
    THEN
        IF p_ps_rec.term_id IS NOT NULL AND p_ps_rec.terms_sequence_number IS NOT NULL
        THEN
            IF p_disc_rec.disc_partial_pmt_flag <> 'Y' AND
              p_disc_rec.disc_partial_pmt_flag <> 'N'
            THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for p_disc_rec.disc_partial_pmt_flag' );
                END IF;
               RAISE ar_m_fail;
            END IF;
            -- If calc_disc_on_lines not in ('Y', 'N', 'I', 'L', 'T', 'F')
            -- Exit with error
            IF p_disc_rec.calc_disc_on_lines <> 'Y' AND
               p_disc_rec.calc_disc_on_lines <> 'N' AND
               p_disc_rec.calc_disc_on_lines <> 'I' AND
               p_disc_rec.calc_disc_on_lines <> 'L' AND
               p_disc_rec.calc_disc_on_lines <> 'T' AND
               p_disc_rec.calc_disc_on_lines <> 'F'
            THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for p_disc_rec.calc_disc_on_lines' );
                END IF;
                RAISE ar_m_fail;
            END IF;
        END IF;
    END IF;
    -- If earned_both_flag <> AR_EARNED_INDICATOR  AND <> AR_BOTH_INDICATOR
    -- exit with error
    IF ( p_disc_rec.earned_both_flag <> AR_EARNED_INDICATOR AND
         p_disc_rec.earned_both_flag <> AR_BOTH_INDICATOR ) THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for p_disc_rec.earned_both_flag' );
       END IF;
         RAISE ar_m_fail;
    END IF;
    -- If Select_flag <> TRUE AND <> FALSE
    -- exit with error
    IF ( p_select_flag <> TRUE AND p_select_flag <> FALSE ) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for p_select_flag. Must be TRUE or FALSE.' );
        END IF;
         RAISE ar_m_fail;
    END IF;
    -- If payment_schedule_id <= 0
    -- exit with error
    IF ( p_ps_rec.payment_schedule_id <= 0 ) THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for
         p_ps_rec.payment_schedule_id. Must be greater than zero.' );
       END IF;
         RAISE ar_m_fail;
    END IF;
    IF p_select_flag = FALSE
    THEN
        IF ( p_ps_rec.term_id IS NULL )
        THEN
            p_ps_rec.term_id := AR_NO_TERM;
        ELSIF p_ps_rec.term_id < 0
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for p_ps_rec.term_id. Must be greater than zero. ' );
            END IF;
            RAISE ar_m_fail;
        END IF;
        IF p_ps_rec.terms_sequence_number IS NULL
        THEN
            p_ps_rec.terms_sequence_number := AR_NO_TERM;
        ELSIF ( p_ps_rec.terms_sequence_number < 0 )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'arp_calculate_discount.check_input : Invalid value for
            p_ps_rec.terms_sequence_number. Must be greater than zero. ' );
            END IF;
            RAISE ar_m_fail;
        END IF;
        IF ( p_ps_rec.trx_date IS NULL ) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'arp_calculate_discount.check_input : p_ps_rec.trx_date is NULL. Must have a value. ');
            END IF;
            RAISE ar_m_fail;
        END IF;
        IF ( p_ps_rec.amount_due_original IS NULL )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'arp_calculate_discount.check_input : p_ps_rec.amount_due_original is NULL . Must have a value. ');
            END IF;
            RAISE ar_m_fail;
        END IF;
        IF ( p_ps_rec.invoice_currency_code IS NULL ) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'arp_calculate_discount.check_input : p_ps_rec.invoice_currency_code is NULL . Must have a value. ');
            END IF;
            RAISE ar_m_fail;
        END IF;
        IF ( p_ps_rec.discount_taken_earned IS NULL ) THEN
            p_ps_rec.discount_taken_earned := 0;
        END IF;
        IF ( p_ps_rec.discount_taken_unearned IS NULL ) THEN
             p_ps_rec.discount_taken_unearned := 0;
        END IF;
        IF ( p_ps_rec.amount_line_items_original IS NULL ) THEN
             p_ps_rec.amount_line_items_original := 0;
        END IF;
    END IF;
    -- else
    -- If Select_flag = False
    -- If term_id = NULL
    -- term_id = AR_NO_TERM
    -- else
    -- If term_id <= 0
    -- exit with error
    -- If term_sequence_number = NULL
    -- term_sequence_number = AR_NO_TERM
    -- else
    -- If term_sequence_number <= 0
    -- exit with error
    -- If trx_date = NULL
    -- exit with error
    -- If amount_due_original = NULL
    -- exit with error
    -- else
    -- If amount_due_remaining = NULL
    -- exit with error
    -- else
    -- If invoice_currency_code = NULL
    -- exit with error
    -- else
    -- If disc_earned = NULL
    -- Set discount earned = 0
    -- If disc_unearned = NULL
    -- Set disc_unearned = 0
    -- If lines_original = NULL
    -- Set lines_original = 0
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.check_input() -' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug( 'Exception: arp_calculate_discount.check_input()' );
           END IF;
           RAISE;
END check_input;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    decrease_discounts_to_maxd                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Decrease Discounts so that maximum discounts not exceeded.             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL  PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_ps_rec - Payment Schedule Record  |
 |                                                                           |
 |              IN OUT:                                                      |
 |                      p_disc_rec - Discount Record                  |
 |                      p_earned_discount - Earned Discount                  |
 |   			p_unearned_discount - Unearned Discount              |
 |  									     |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Shiv Ragunat - 05/24/95                 |
 |	jbeckett	06-JUL-2004	Bug 3527600: changes to allow for    |
 |					negative discounts.                  |
 |                                                                           |
 +===========================================================================*/
--
PROCEDURE decrease_discounts_to_maxd(
    p_disc_rec IN OUT NOCOPY discount_record_type,
    p_ps_rec IN ar_payment_schedules%ROWTYPE,
    p_earned_disc IN OUT NOCOPY NUMBER,
    p_unearned_disc IN OUT NOCOPY NUMBER) IS
    l_max_disc NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.decrease_discounts_to_maxd() +' );
    END IF;
--
    IF ( ABS(p_disc_rec.max_disc) < ABS(p_earned_disc) ) THEN
	p_earned_disc := p_disc_rec.max_disc;
	p_unearned_disc := 0;
    ELSE
       l_max_disc := p_disc_rec.max_disc - p_earned_disc;
       IF ( ABS(l_max_disc) < ABS(p_unearned_disc) ) THEN
            p_unearned_disc := l_max_disc;
       END IF;
    END IF;
    -- If  max_disc < out_earned_disc
    -- set earned_discount = max_disc and unearned_disc = 0
    -- else
    -- If max-earned < full unearned discount
    -- set unearned discount = max-earned
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.decrease_discounts_to_maxd() -' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug( 'Exception: arp_calculate_discount.decrease_discounts_to_maxd()');
           END IF;
           RAISE;
END decrease_discounts_to_maxd;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 | discounts_cover  - Validate args, init variables and call actual discounts|
 |                    procedure                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function validates args, init variables and calls actual discounts|
 |    procedure                                                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      ARP_CALCULATE_DISCOUNT.calculate_discounts                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  08/10/95 - Created by Ganesh Vaidee               |
 |  26-Feb-1999    Debbie Jancis     Added cash_receipt_id to arguments as   |
 |                                   per cpg bug 627518.                     |
 +===========================================================================*/
PROCEDURE discounts_cover(
     p_mode          IN VARCHAR2,
     p_invoice_currency_code IN ar_cash_receipts.currency_code%TYPE,
     p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
     p_term_id IN ra_terms.term_id%TYPE,
     p_terms_sequence_number IN ar_payment_schedules.terms_sequence_number%TYPE,
     p_trx_date IN ar_payment_schedules.trx_date%TYPE,
     p_apply_date IN ar_cash_receipts.receipt_date%TYPE,
     p_grace_days IN NUMBER,
     p_default_amt_apply_flag  IN VARCHAR2,
     p_partial_discount_flag IN VARCHAR2,
     p_calc_discount_on_lines_flag IN VARCHAR2,
     p_allow_overapp_flag IN VARCHAR2,
     p_close_invoice_flag IN VARCHAR2,
     p_earned_disc_pct IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_best_disc_pct IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_input_amount   IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_original IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_remaining IN ar_payment_schedules.amount_due_remaining%TYPE,
     p_discount_taken_earned IN ar_payment_schedules.amount_due_original%TYPE,
     p_discount_taken_unearned IN
                          ar_payment_schedules.amount_due_original%TYPE,
     p_amount_line_items_original IN
                          ar_payment_schedules.amount_line_items_original%TYPE,
     p_out_discount_date    IN OUT NOCOPY DATE,
     p_out_earned_discount  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_out_unearned_discount  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_out_amount_to_apply  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_out_discount_to_take  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_module_name  IN VARCHAR2,
     p_module_version IN VARCHAR2,
     p_cash_receipt_id IN NUMBER  ,
     p_allow_discount IN VARCHAR2 DEFAULT 'Y' ) IS  /* Bug fix 3450317 */
--
l_use_max_cash_flag    CHAR := 'Y';
l_earned_both_flag     CHAR := 'E';
l_select_flag          CHAR := 'N';
--
l_error_code           NUMBER;
l_close_invoice_flag   VARCHAR2(10);
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.discounts_cover()+' );
    END IF;
  -- ARTA changes calls TA discount cover for TA installation
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
     NULL; -- Do Nothing;
     -- Removed ARTA logic for Bug 4936298
  ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('discounts_cover: ' ||  'Mode              : '||p_mode );
       arp_standard.debug('discounts_cover: ' ||  'Currency Code     : '||p_invoice_currency_code );
       arp_standard.debug('discounts_cover: ' ||  'PS ID             : '||p_ps_id );
       arp_standard.debug('discounts_cover: ' ||  'Term Id           : '||p_term_id );
       arp_standard.debug('discounts_cover: ' ||  'Term Seq Num      : '||p_terms_sequence_number );
       arp_standard.debug('discounts_cover: ' ||  'Trx Date          : '||TO_CHAR( p_trx_date ) );
       arp_standard.debug('discounts_cover: ' ||  'Receipt Date      : '||TO_CHAR( p_trx_date ) );
       arp_standard.debug('discounts_cover: ' ||  'Grace Days        : '||p_grace_days );
       arp_standard.debug('discounts_cover: ' ||  'Part. Disc. Flag  : '||p_partial_discount_flag );
       arp_standard.debug('discounts_cover: ' ||  'Calc. Disc. Lines : '||p_calc_discount_on_lines_flag );
       arp_standard.debug('discounts_cover: ' ||  'Earned Disc. Pct  : '||p_earned_disc_pct );
       arp_standard.debug('discounts_cover: ' ||  'Best Disc. Pct    : '||p_best_disc_pct );
       arp_standard.debug('discounts_cover: ' ||  'Input Amount      : '||p_input_amount );
       arp_standard.debug('discounts_cover: ' ||  'ADO               : '||p_amount_due_original );
       arp_standard.debug('discounts_cover: ' ||  'ADR               : '||p_amount_due_remaining );
       arp_standard.debug('discounts_cover: ' ||  'Disc. Taken Earned: '||p_discount_taken_earned );
       arp_standard.debug('discounts_cover: ' ||  'Disc. Taken Unearn: '||p_discount_taken_unearned );
       arp_standard.debug('discounts_cover: ' ||  'Lines Items Orig. : '||p_amount_line_items_original );
       arp_standard.debug('discounts_cover: ' ||  'Out Discount Date : '||TO_CHAR( p_out_discount_date ) );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_discounts_cover( p_mode, p_invoice_currency_code,
                                       p_ps_id, p_trx_date, p_apply_date );
    END IF;
    --
    l_close_invoice_flag := p_close_invoice_flag;
    --
    -- If TERM_ID or SEQUENCE_NUM then outputs to zeros
    --
    IF ( p_term_id IS NULL OR p_terms_sequence_number IS NULL OR p_allow_discount = 'N' ) THEN /* Bug fix 3450317 */
        p_earned_disc_pct := 0;
        p_best_disc_pct := 0;
        p_out_earned_discount := 0;
        p_out_unearned_discount := 0;
        p_out_discount_to_take := 0; /* Bug fix 3450317 */
        --
        -- Set Output amount to apply
        -- In DEFAULT mode, set amount to apply to the lesser of the
        -- input amount and the amount due remaining. If input is
        -- CLOSE_INVOICE, then use amount due remaining
        --
        -- AR_DEFAULT_DISC
        IF ( p_mode = AR_DEFAULT_DISC OR p_mode = AR_DEFAULT_NEW_DISC) THEN
            IF ( l_close_invoice_flag = 'Y' ) THEN
                p_out_amount_to_apply := p_amount_due_remaining;
            ELSE
                IF ( p_default_amt_apply_flag <> 'PMT' ) THEN
		/* Bug 8747163 */
                     IF ( p_amount_due_remaining < p_input_amount ) THEN
			p_out_amount_to_apply := NVL( p_amount_due_remaining, 0 );
		     ELSE
		        p_out_amount_to_apply :=  NVL( p_input_amount, 0 );
		     END IF;
                ELSE  /** ADR <  0 ***/
                    IF ( p_amount_due_remaining < 0 ) THEN
                        p_out_amount_to_apply := p_amount_due_remaining;
                    ELSE  /*** ADR >= 0 ***/
                        IF ( p_input_amount < 0 ) THEN /* input amount < 0 */
                            p_out_amount_to_apply := 0;
                        ELSE /* IF ADR < input amount */
                            IF ( p_amount_due_remaining < p_input_amount ) THEN
                                p_out_amount_to_apply :=
                                             NVL( p_amount_due_remaining, 0 );
                            ELSE /* ADR >= inout amount */
                                p_out_amount_to_apply :=
                                             NVL( p_input_amount, 0 );
                            END IF; /* /* IF ADR < input amount */
                        END IF; /* input amount < 0 */
                    END IF; /* ADR <  0 ***/
                END IF; /** p_default_amt_apply_flag <> 'PMT' */
            END IF; /* l_close_invoice_flag = 'Y' */
        END IF;  /*  p_mode = 1 */
        --
        RETURN;
    END IF; /* p_term_id IS NULL OR p_terms_sequence_number IS NULL */
    --
    -- If mode is DIRECT and Over app flag is 'Y' then max cash flag is FALSE
    --
    IF ( p_mode = AR_DIRECT_DISC OR p_mode = AR_DIRECT_NEW_DISC ) THEN /* DIRECT   */
        IF ( p_allow_overapp_flag = 'Y' ) THEN
            l_use_max_cash_flag := 'N';
        ELSE
            l_use_max_cash_flag := 'Y';
        END IF;
    --
    -- If profile option 'Default Amount Applied' is 'Remaining amt of inv',
    -- close invoice flag is 'Y'
    ELSE /* DEFAULT MODE */
        IF ( p_default_amt_apply_flag <> 'PMT' ) THEN
            l_close_invoice_flag := 'Y';
        END IF;
    END IF;
    --
    -- set earned_both_flag to BOTH if discounts not allowed on partial
    -- payments. This is because discount package would return 0 discounts if
    -- earned discount alone is insufficient to close the payment schedule.
    -- We want to return a default (OUT_DISC_TO_TAKE) of zero in that case,
    -- but still return earned and unearned discounts if it is possible to
    -- close the payment schedule using unearned discount.
    --
    IF ( p_partial_discount_flag = 'N' ) THEN
        l_earned_both_flag := 'B';
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('discounts_cover: ' ||  'arp_calculate_discount.calc_discount()-' );
    END IF;
    --
    arp_calculate_discount.calculate_discounts( p_input_amount,
                                                p_grace_days,
                                                p_apply_date,
                                                p_partial_discount_flag,
                                                p_calc_discount_on_lines_flag,
                                                l_earned_both_flag,
                                                l_use_max_cash_flag,
                                                p_default_amt_apply_flag,
                                                p_earned_disc_pct,
                                                p_best_disc_pct,
                                                p_out_earned_discount,
                                                p_out_unearned_discount,
                                                p_out_discount_date,
                                                p_out_amount_to_apply,
                                                l_close_invoice_flag,
                                                p_ps_id,
                                                p_term_id,
                                                p_terms_sequence_number,
                                                p_trx_date,
                                                p_amount_due_original,
                                                p_amount_due_remaining,
                                                p_discount_taken_earned,
                                                p_discount_taken_unearned,
                                                p_amount_line_items_original,
                                                p_invoice_currency_code,
                                                l_select_flag,
                                                p_mode,
                                                l_error_code,
                                                p_cash_receipt_id );
    --
    p_out_discount_to_take := p_out_earned_discount;
    --
    -- If discount is not allowed on partial payments, then
    -- OUT_DISC_TO_TAKE and OUT_AMT_TO_APPLY must be changed if
    -- unearned discount was required to close the payment schedule.
    --
    IF ( p_partial_discount_flag  = 'N' ) THEN
        IF ( p_out_unearned_discount <> 0 ) THEN
            IF ( p_mode = 0 ) THEN /* DIRECT */
                p_out_discount_to_take := 0;
            ELSE /* DEFAULT MODE */
                --
                -- Add unearned discount to amount to apply
                --
                IF ( l_close_invoice_flag = 'N' ) THEN
                    p_out_amount_to_apply := p_out_amount_to_apply +
                                             p_out_unearned_discount;
                 --
                 -- If new amount to apply exceeds amount available,
                 -- set OUT_DISC_TO_TAKE = 0 and OUT_AMT_TO_APPLY = amount
                 -- available
                 --
                    IF ( p_out_amount_to_apply > p_input_amount ) THEN
                        p_out_discount_to_take := 0;
                        p_out_amount_to_apply := p_input_amount;
                    END IF;
                END IF;
            END IF; /* DEFAULT MODE */
        END IF; /* unearned discount <> zero */
    END IF; /* discount on partial payments not allowed */
    --
  END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.discounts_cover()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug( 'EXCEPTION: arp_calculate_discount.discounts_cover'
 );
             END IF;
             RAISE;
END discounts_cover;


--  created an overloaded discounts_cover routine which will call the
--  above procedure with a NULL for cash_receipt_id.   This was added for
--  Bug 627518.    AR forms will call this function because they will not
--  use Cash_receipt_id for calculating discounts.

PROCEDURE discounts_cover(
     p_mode          IN VARCHAR2,
     p_invoice_currency_code IN ar_cash_receipts.currency_code%TYPE,
     p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
     p_term_id IN ra_terms.term_id%TYPE,
     p_terms_sequence_number IN ar_payment_schedules.terms_sequence_number%TYPE,
     p_trx_date IN ar_payment_schedules.trx_date%TYPE,
     p_apply_date IN ar_cash_receipts.receipt_date%TYPE,
     p_grace_days IN NUMBER,
     p_default_amt_apply_flag  IN VARCHAR2,
     p_partial_discount_flag IN VARCHAR2,
     p_calc_discount_on_lines_flag IN VARCHAR2,
     p_allow_overapp_flag IN VARCHAR2,
     p_close_invoice_flag IN VARCHAR2,
     p_earned_disc_pct IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_best_disc_pct IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_input_amount   IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_original IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_remaining IN ar_payment_schedules.amount_due_remaining%TYPE,
     p_discount_taken_earned IN ar_payment_schedules.amount_due_original%TYPE,
     p_discount_taken_unearned IN
                          ar_payment_schedules.amount_due_original%TYPE,
     p_amount_line_items_original IN
                          ar_payment_schedules.amount_line_items_original%TYPE,
     p_out_discount_date    IN OUT NOCOPY DATE,
     p_out_earned_discount  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_out_unearned_discount  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_out_amount_to_apply  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_out_discount_to_take  IN OUT NOCOPY
                          ar_payment_schedules.amount_due_original%TYPE,
     p_module_name  IN VARCHAR2,
     p_module_version IN VARCHAR2 ,
     p_allow_discount IN VARCHAR2 DEFAULT 'Y' ) IS /* Bug fix 3450317 */
BEGIN
   -- ARTA changes calls TA discount cover for TA installation
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
     NULL; -- Do Nothing
     -- Removed ARTA logic for Bug 4936298
  ELSE
     ARP_CALCULATE_DISCOUNT.discounts_cover( p_mode,
                                    p_invoice_currency_code,
                                    p_ps_id,
                                    p_term_id,
                                    p_terms_sequence_number,
                                    p_trx_date,
                                    p_apply_date,
                                    p_grace_days,
                                    p_default_amt_apply_flag,
                                    p_partial_discount_flag,
                                    p_calc_discount_on_lines_flag,
                                    p_allow_overapp_flag,
                                    p_close_invoice_flag,
                                    p_earned_disc_pct,
                                    p_best_disc_pct,
                                    p_input_amount,
                                    p_amount_due_original,
                                    p_amount_due_remaining,
                                    p_discount_taken_earned,
                                    p_discount_taken_unearned,
                                    p_amount_line_items_original,
                                    p_out_discount_date,
                                    p_out_earned_discount,
                                    p_out_unearned_discount,
                                    p_out_amount_to_apply,
                                    p_out_discount_to_take,
                                    p_module_name,
                                    p_module_version,
                                    NULL,
                                    p_allow_discount); /* Bug fix 3450317 */
  END IF;
END discounts_cover;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_discounts_cover                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to calc_discount procedure                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_standard.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_mode - Mode                                             |
 |                 p_currrency_code - Invoice Currency Code                  |
 |                 p_ps_id - Payment Schedule ID                             |
 |                 p_term_id - Term ID                                       |
 |                 p_trx_date - Transaction Date                             |
 |                 p_apply_date - receipt date                               |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/10/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_discounts_cover(
     p_mode          IN VARCHAR2,
     p_invoice_currency_code IN ar_cash_receipts.currency_code%TYPE,
     p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
     p_trx_date IN ar_payment_schedules.trx_date%TYPE,
     p_apply_date IN ar_cash_receipts.receipt_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.validate_args_discounts_cover()+' );
    END IF;
    --
    IF ( p_mode is NULL OR p_invoice_currency_code IS NULL OR
         p_ps_id IS NULL OR p_trx_date IS NULL OR
         p_apply_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_calculate_discount.validate_args_discounts_cover()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('validate_args_discounts_cover: ' ||
                   'EXCEPTION: arp_calculate_discount.validate_args_calc_discoun
ts' );
              END IF;
              RAISE;
END validate_args_discounts_cover;

-- AR/TA Changes
PROCEDURE set_g_called_from (p_called_from IN varchar2) IS

BEGIN
     IF ( p_called_from = 'MANUAL') THEN
        arp_calculate_discount.g_called_from := 'MANUAL' ;
     END IF ;

EXCEPTION
     WHEN OTHERS THEN
          NULL ;
END SET_G_CALLED_FROM ;
--
--
END arp_calculate_discount;

/
