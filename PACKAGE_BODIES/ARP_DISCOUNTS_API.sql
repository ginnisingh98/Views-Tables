--------------------------------------------------------
--  DDL for Package Body ARP_DISCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DISCOUNTS_API" AS
/* $Header: ARRUDIAB.pls 120.7.12010000.4 2009/08/14 12:45:25 rvelidi ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_discount                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calculate the discount allowed on a payment and the remaining          |
 |    on the invoice.							     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ps_id - payment schedule id of the invoice              |
 |                 p_apply_date - application date of the payment	     |
 |                 p_in_applied_amount - amount being applied 		     |
 |                 p_grace_flag - Flag that decides grace days to be applied |
 |				  in discount calculation or not.	     |
 |									     |
 |              IN OUT:                                                      |
 |									     |
 |              OUT:                                                         |
 |		  p_out_discount - discount available on the payment amount  |
 |		  p_out_remaining_amount - remaining amount on the invoice   |
 |			after application amount and discounts are taken     |
 |									     |
 | MODIFICATION HISTORY 						     |
 |  01/25/01	R Yeluri	Created 				     |
 |  09/10/04    J Beckett       Bug 3866488 - corrected the sql to fetch     |
 |				grace days from cust acct profile if none    |
 |				exists for site use.			     |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
/*Bug 5223829 introduced new parameter for iReceivables*/
PROCEDURE get_discount (
	p_ps_id			IN	ar_payment_schedules.payment_schedule_id%TYPE,
  	p_apply_date           	IN     	DATE,
       	p_in_applied_amount    	IN     	NUMBER,
	p_grace_days_flag       IN	VARCHAR2,
        p_out_discount         	OUT NOCOPY    	NUMBER,
        p_out_rem_amt_rcpt 	OUT NOCOPY    	NUMBER,
        p_out_rem_amt_inv 	OUT NOCOPY    	NUMBER,
        P_called_from           IN              VARCHAR2) IS

p_ps_rec         ar_payment_schedules%ROWTYPE;
p_disc_rec       arp_calculate_discount.discount_record_type;

l_grace_days            NUMBER;
l_customer_id            NUMBER;
l_site_use_id            NUMBER;

l_use_max_cash_flag	VARCHAR2(2);
l_earned_both_flag	VARCHAR2(2);
l_default_amt_app	VARCHAR2(241);
l_error_code		NUMBER;
l_select_flag		VARCHAR2(1);
l_close_invoice_flag 	VARCHAR2(2);
l_mode			NUMBER;
l_earned_disc_pct 	NUMBER;
l_best_disc_pct 	NUMBER;
l_out_earned_disc 	NUMBER;
l_out_unearned_disc 	NUMBER;
l_out_discount_date 	DATE;
l_out_amt_to_apply 	NUMBER;
l_cash_receipt_id 	NUMBER;
l_site_level_profile    BOOLEAN; -- Bug 3866488
l_amt_due_rem           NUMBER; /*Bug 5223829*/
l_amt_in_dispute        ar_payment_schedules.amount_in_dispute%TYPE; /*Bug 5223829*/

BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug( 'arp_discounts_api.get_discount() +');
	END IF;

	-- Get payment schedule info and populate the payment schedule record
	p_ps_rec.payment_schedule_id := p_ps_id;
	arp_calculate_discount.get_payment_schedule_info(p_disc_rec, p_ps_rec);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_discount: ' ||  'initialized payment schedule record');
	END IF;

     -- Get Customer Id and Site Use Id to obtain any grace days
     -- available for the Customer.
     BEGIN
	SELECT	customer_id, customer_site_use_id
	INTO	l_customer_id, l_site_use_id
	FROM	ar_payment_schedules
	WHERE	payment_schedule_id = p_ps_id;

     EXCEPTION
		WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_standard.debug('get_discount: ' || 'No data found for Customer id');
		END IF;
      END;

      -- If grace days is allowed from iReceivables, calculate the
      -- grace days available for the Customer, otherwise grace days is 0
      /* Bug 3866488 - even though a site use id exists, a customer profile
      may not be assigned to it, so the cust account profile must be used */
	if (p_grace_days_flag = 'Y') then
           l_site_level_profile := TRUE;
	   if l_site_use_id is NOT NULL then
             BEGIN
               SELECT  NVL(discount_grace_days, 0)
               INTO    l_grace_days
               FROM    hz_customer_profiles
               WHERE   cust_account_id = l_customer_id
               AND     site_use_id     = l_site_use_id;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_site_level_profile := FALSE;

               WHEN OTHERS THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('get_discount: ' || 'EXCEPTION: Error selecting discount_grace_days from site level customer profile ');
                   arp_util.debug('Validate_amount: ' || 'site_use_id  =  ' ||TO_CHAR(l_site_use_id));
                 END IF;
                 RAISE;
             END;
           END IF;

	   IF ( l_site_use_id IS NULL OR NOT l_site_level_profile ) THEN
               SELECT  NVL(discount_grace_days, 0)
               INTO    l_grace_days
               FROM    hz_customer_profiles
               WHERE   cust_account_id = l_customer_id
	       AND     site_use_id IS NULL;
           end if;

	 else
		l_grace_days := 0;
	 end if;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_discount: ' ||  'grace days:'||l_grace_days );
	END IF;


	-- Initilaize various variables necessary to be passed into
	-- calculate discounts routine.
        l_use_max_cash_flag  := 'Y' ;
/*Bug 4288015 Discount should be earned discount */
        l_earned_both_flag   := 'E' ; /*does B imply both earned and Unearned */
        l_default_amt_app    := 'PMT' ;
        l_error_code := '0' ;
        l_select_flag := 'N' ; -- set to 'N' if select_flag is FALSE
        l_close_invoice_flag := 'N' ; --is Y if mode=default and l_default_amt_app<>PMT
				      --Need to check on this, this needs to be a N
        l_mode := 1 ; -- default mode

        l_earned_disc_pct := 0 ;
        l_best_disc_pct := 0 ;
        l_out_earned_disc := 0 ;
        l_out_unearned_disc := 0 ;
        l_out_discount_date := p_apply_date ;
        l_out_amt_to_apply := 0 ;
        l_cash_receipt_id := 0 ;
/*Bug 5223829 put the logic to consider for amount in dispute when called from iReceivables*/
        IF p_called_from ='OIR' THEN
          l_amt_due_rem  := p_ps_rec.amount_due_remaining - nvl(p_ps_rec.amount_in_dispute,0);
          l_amt_in_dispute := p_ps_rec.amount_in_dispute;
        ELSE
          l_amt_due_rem  := p_ps_rec.amount_due_remaining;
          l_amt_in_dispute := NULL;
        END IF;

	-- Call the discounts package.
	arp_calculate_discount.calculate_discounts(
            p_in_applied_amount, --input
            l_grace_days,
            p_apply_date, --input
            p_disc_rec.disc_partial_pmt_flag,
            p_disc_rec.calc_disc_on_lines,
            l_earned_both_flag,
            l_use_max_cash_flag,
            l_default_amt_app,
            l_earned_disc_pct,
            l_best_disc_pct,
            l_out_earned_disc,
            l_out_unearned_disc,
            l_out_discount_date,
            l_out_amt_to_apply,
            l_close_invoice_flag,
            p_ps_id, --input
            p_ps_rec.term_id,
            p_ps_rec.terms_sequence_number,
            p_ps_rec.trx_date,
            p_ps_rec.amount_due_original,
            l_amt_due_rem,/*Bug 5223829 callled in place of  p_ps_rec.amount_due_remaining*/
            NVL(p_ps_rec.discount_taken_earned,0),
            NVL(p_ps_rec.discount_taken_unearned,0),
            NVL(p_ps_rec.amount_line_items_original,0),
            p_ps_rec.invoice_currency_code,
            l_select_flag,
            l_mode,
            l_error_code,
            l_cash_receipt_id,
            p_called_from,  /*Bug 5223829*/
            l_amt_in_dispute /*Bug 5223829*/
   );

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_discount: ' ||  'earned discount :'|| l_out_earned_disc );
	   arp_standard.debug('get_discount: ' ||  'unearned discount :'|| l_out_unearned_disc );
	END IF;

 -- This is the total discount available on the payment schedule
 -- This program is intended only to give out NOCOPY earned disocunts.
 -- There will be no unearned discounts, hence even if there are
 -- unearned discounts, the total disocunt is zero.

   /* Bug 4460264 - allows for negative discount */
   p_out_discount := l_out_earned_disc;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_discount: ' ||  'Input Amount applied :'|| p_in_applied_amount);
	   arp_standard.debug('get_discount: ' ||  'ADR on the Invoice :'||p_ps_rec.amount_due_remaining);
	END IF;


 -- This calculates if the receipt application plus the discount can
 -- close out NOCOPY the invoice. If is does, is there any receipt amount being
 -- left as unapplied. If the application plus discount does not close out NOCOPY
 -- the invoice, what is the amount due remaining on the invoice.

  if ((p_out_discount+p_in_applied_amount)
		>= p_ps_rec.amount_due_remaining) then

  	p_out_rem_amt_rcpt := (p_out_discount+p_in_applied_amount)
					- p_ps_rec.amount_due_remaining;
	p_out_rem_amt_inv  := 0;
  else
	p_out_rem_amt_rcpt := 0;
	p_out_rem_amt_inv  := p_ps_rec.amount_due_remaining
				- (p_out_discount+p_in_applied_amount);
  end if;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_discount: ' ||  'Total discount :'|| p_out_discount );
	   arp_standard.debug('get_discount: ' ||  'ADR on the Invoice after discount :'||p_out_rem_amt_inv);
	   arp_standard.debug('get_discount: ' ||  'ADR on the Receipt after discount :'||p_out_rem_amt_rcpt);
	   arp_standard.debug( 'arp_discounts_api.get_discount() -');
	END IF;


END get_discount;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_max_discount                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calculate the maximum allowable discount for a given payment schedule  |
 |    and the amount needed to close out NOCOPY the invoice. 			     |
 |    on the invoice.                                                        |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ps_id - payment schedule id of the invoice              |
 |                 p_apply_date - application date of the payment            |
 |                 p_grace_days_flag - Allow grace days Yes/No 		     |
 |                                                                           |
 |              IN OUT:                                                      |
 |                                                                           |
 |              OUT:                                                         |
 |                p_out_discount - Max discount available on the payment     |
 |				   schedule				     |
 |                p_out_amount_applied - amount needed minus the discount    |
 |				       available needed to close the invoice |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  01/25/01    R Yeluri        Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_max_discount (
        p_ps_id                 IN      ar_payment_schedules.payment_schedule_id%TYPE,
        p_apply_date            IN      DATE,
        p_grace_days_flag     	IN      VARCHAR2,
        p_out_discount          OUT NOCOPY     NUMBER,
        p_out_applied_amt	OUT NOCOPY     NUMBER) IS

p_ps_rec         ar_payment_schedules%ROWTYPE;
p_disc_rec       arp_calculate_discount.discount_record_type;

p_mode      	NUMBER;
l_customer_id	NUMBER;
l_site_use_id	NUMBER;
l_grace_days	NUMBER;
l_discount_date	DATE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug( 'arp_discounts_api.get_max_discount() +');
	   arp_standard.debug('get_max_discount: ' ||  'Payment schedule Id :'|| p_ps_id);
	   arp_standard.debug('get_max_discount: ' ||  'Apply Date :'|| p_apply_date );
	   arp_standard.debug('get_max_discount: ' ||  'Allow Grace Days :'|| p_grace_days_flag );
	END IF;

	p_mode := 1; --default mode

     -- Get Customer Id and Site Use Id to obtain any grace days
     -- available for the Customer.
      BEGIN
	SELECT  customer_id, customer_site_use_id
        INTO    l_customer_id, l_site_use_id
        FROM    ar_payment_schedules
        WHERE   payment_schedule_id = p_ps_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_standard.debug('get_max_discount: ' || 'No Customer Data Found');
		END IF;
       END;


	-- Grace days
	-- If grace days is allowed from iReceivables, calculate the
      	-- grace days available for the Customer, otherwise grace days is 0

	if (p_grace_days_flag = 'Y') then
	    if l_site_use_id is NOT NULL then
               SELECT  NVL(discount_grace_days, 0)
               INTO    l_grace_days
               FROM    hz_customer_profiles
               WHERE   cust_account_id = l_customer_id
               AND     site_use_id     = l_site_use_id;
            else
               SELECT  NVL(discount_grace_days, 0)
               INTO    l_grace_days
               FROM    hz_customer_profiles
               WHERE   cust_account_id = l_customer_id;
            end if;

         else
                l_grace_days := 0;
         end if;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_max_discount: ' ||  'Grace Days :'|| l_grace_days );
	END IF;

	-- We need this following set of statements, because the
	-- determine_max_discount always calculates max discount
	-- while taking into consideration grace days
	-- The requirement of iReceivables is that if the grace_days_flag
	-- is FALSE, then the max discount should eliminate any
	-- grace days available during discount calculation
       BEGIN
	SELECT 	discount_date
	INTO 	l_discount_date
        FROM   	ar_trx_discounts_v
        WHERE 	payment_schedule_id  = p_ps_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_standard.debug('get_max_discount: ' ||  'error getting discount date');
		END IF;
       END;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_max_discount: ' ||  'Discount Date :'|| l_discount_date );
	END IF;

	-- Populate the payment schedule record.
	p_ps_rec.payment_schedule_id := p_ps_id;
        arp_calculate_discount.get_payment_schedule_info(p_disc_rec, p_ps_rec);
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_max_discount: ' ||  'Initialized the payment schedule record');
	END IF;

	if ((p_apply_date - l_grace_days) > l_discount_date) then
	   --implies the application date is past the discount date
	   --including the grace days, hence no disocunt is available

		p_out_discount := 0;
	else

		--Get Discount Percentages
		arp_calculate_discount.get_discount_percentages (p_disc_rec, p_ps_rec);
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_standard.debug('get_max_discount: ' ||  'Calculated Discount percentages');
		END IF;

    		-- Correct percentages for lines-only(ardline) discount if necessary.
    		IF p_disc_rec.calc_disc_on_lines <> 'I' AND
    			p_disc_rec.calc_disc_on_lines <> 'N' THEN
    		   arp_calculate_discount.correct_lines_only_discounts ( p_disc_rec, p_ps_rec );
    		END IF;
    		--

    		-- If no discount percentages, set discounts to zero.
    		IF ( p_disc_rec.best_disc_pct = 0 ) THEN
        		p_out_discount := 0 ;
        		p_disc_rec.earned_disc_pct := 0;
    		END IF;

		--Calculate max discount available
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_standard.debug('get_max_discount: ' ||  'Calling MAX discount routine() +');
		END IF;
		arp_calculate_discount.determine_max_allowed_disc
					( p_mode, p_disc_rec, p_ps_rec );


		p_out_discount := nvl(p_disc_rec.max_disc,0);


	end if;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_max_discount: ' ||  'Maximum Available Discount :'|| p_out_discount);
	END IF;

	if (p_out_discount > 0) then
		p_out_applied_amt := p_ps_rec.amount_due_remaining - p_out_discount;
	else
		p_out_applied_amt := p_ps_rec.amount_due_remaining;
	end if;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('get_max_discount: ' ||  'Amount Needed to Close the Invoice :'|| p_out_applied_amt);
	   arp_standard.debug( 'arp_discounts_api.get_max_discount() -');
	END IF;

END get_max_discount;


FUNCTION get_available_disc_on_inv( p_applied_payment_schedule_id  IN  NUMBER,
		                    p_apply_date                   IN  DATE,
				    p_amount_to_be_applied         IN NUMBER DEFAULT NULL) RETURN NUMBER IS

  l_return_status              VARCHAR2(200);
  l_discount_max_allowed       NUMBER;
  l_discount_earned_allowed    NUMBER;
  l_discount_earned            NUMBER;
  l_discount_unearned          NUMBER;
  l_new_amount_due_remaining   NUMBER;
  l_amount_to_be_applied       NUMBER;
  l_discount                   NUMBER;

  l_customer_id                 NUMBER;
  l_bill_to_site_use_id         NUMBER;
  l_applied_payment_schedule_id NUMBER;
  l_term_id                     NUMBER;
  l_installment                 NUMBER;
  l_trx_date                    DATE;
  l_apply_date                  DATE;
  l_amount_due_original         NUMBER;
  l_amount_due_remaining        NUMBER;
  l_trx_currency_code           VARCHAR2(10);
  l_discount_taken_unearned     NUMBER;
  l_discount_taken_earned       NUMBER;
  l_trx_exchange_rate           NUMBER;
  l_allow_overappln_flag        VARCHAR2(2);
  l_partial_discount_flag       VARCHAR2(1);
  l_calc_flag                   VARCHAR2(1);
  l_calc_disc_on_line           VARCHAR2(1);
  l_amount_line_items_original  NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'Get_Available_Disc_On_Inv()+' );
    arp_standard.debug( 'p_applied_payment_schedule_id :-' || p_applied_payment_schedule_id );
    arp_standard.debug( 'p_amount_to_be_applied          ' || p_amount_to_be_applied );
    arp_standard.debug( 'p_apply_date :-'                  || p_apply_date );
  END IF;

  l_applied_payment_schedule_id := p_applied_payment_schedule_id;
  l_apply_date                  := p_apply_date;

  BEGIN
      select ps.customer_id,
	     ps.customer_site_use_id,
	     ps.term_id,
	     ps.terms_sequence_number,
	     ps.trx_date,
	     ps.amount_due_original,
	     ps.amount_due_remaining,
	     ps.invoice_currency_code,
	     ps.discount_taken_unearned,
	     ps.discount_taken_earned,
	     ps.exchange_rate,
	     ctt.allow_overapplication_flag,
	     tr.partial_discount_flag ,
	     tr.calc_discount_on_lines_flag,
	     ps.amount_line_items_original
      into
	      l_customer_id,
	      l_bill_to_site_use_id,
	      l_term_id,
	      l_installment,
	      l_trx_date,
	      l_amount_due_original,
	      l_amount_due_remaining,
	      l_trx_currency_code,
	      l_discount_taken_unearned,
	      l_discount_taken_earned,
	      l_trx_exchange_rate,
	      l_allow_overappln_flag,
	      l_partial_discount_flag,
	      l_calc_disc_on_line,
              l_amount_line_items_original
      from ar_payment_schedules ps,
	   ra_cust_trx_types ctt,
	   ra_terms tr
      where ps.payment_schedule_id  = l_applied_payment_schedule_id
      AND tr.term_id = ps.term_id
      AND ps.cust_trx_type_id = ctt.cust_trx_type_id;

      l_calc_flag := 'Y';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_calc_flag := 'N';
     l_discount  := 0;
  END;

  IF NVL(l_calc_flag,'N') = 'Y' THEN

      IF NVL(p_amount_to_be_applied,0) <> 0 THEN
	l_amount_to_be_applied := p_amount_to_be_applied;
      END IF;

      ar_receipt_lib_pvt.Default_disc_and_amt_applied(
	 p_customer_id                 => l_customer_id,
	 p_bill_to_site_use_id         => l_bill_to_site_use_id,
	 p_applied_payment_schedule_id => l_applied_payment_schedule_id,
	 p_term_id                     => l_term_id,
	 p_installment                 => l_installment,
	 p_trx_date                    => l_trx_date,
	 p_apply_date                  => l_apply_date,
	 p_amount_due_original         => l_amount_due_original,
	 p_amount_due_remaining        => l_amount_due_remaining,
	 p_trx_currency_code           => l_trx_currency_code,
	 p_allow_overappln_flag        => l_allow_overappln_flag,
	 p_discount_taken_unearned     => l_discount_taken_unearned,
	 p_discount_taken_earned       => l_discount_taken_earned,
	 p_trx_exchange_rate           => l_trx_exchange_rate,
	 p_cr_date                     => NULL,
	 p_cr_currency_code            => NULL,
	 p_cr_exchange_rate            => NULL,
	 p_cr_unapp_amount             => NULL,
	 p_calc_discount_on_lines_flag => l_calc_disc_on_line,
	 p_partial_discount_flag       => l_partial_discount_flag,
	 p_amount_line_items_original  => l_amount_line_items_original,
	 p_customer_trx_line_id        => NULL,
	 p_trx_line_amount             => NULL,
	 p_llca_type                   => NULL,
	 p_amount_applied              => l_amount_to_be_applied,
	 p_discount                    => l_discount,
	 p_discount_max_allowed        => l_discount_max_allowed,
	 p_discount_earned_allowed     => l_discount_earned_allowed,
	 p_discount_earned             => l_discount_earned,
	 p_discount_unearned           => l_discount_unearned,
	 p_new_amount_due_remaining    => l_new_amount_due_remaining,
	 p_return_status               => l_return_status
      );

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug( 'l_amount_to_be_applied     :- '|| l_amount_to_be_applied );
	arp_standard.debug( 'l_discount                 :- '|| l_discount );
	arp_standard.debug( 'l_discount_max_allowed     :- '|| l_discount_max_allowed );
	arp_standard.debug( 'l_discount_earned_allowed  :- '|| l_discount_earned_allowed );
	arp_standard.debug( 'l_discount_earned          :- '|| l_discount_earned );
	arp_standard.debug( 'l_discount_unearned        :- '|| l_discount_unearned );
	arp_standard.debug( 'l_new_amount_due_remaining :- '|| l_new_amount_due_remaining );
	arp_standard.debug( 'l_return_status            :- '|| l_return_status );
      END IF;

      IF NVL(l_partial_discount_flag,'N') = 'N' THEN
	IF l_amount_to_be_applied + l_discount <> l_amount_due_remaining THEN
	  RETURN 0;
	ELSE
	  RETURN l_discount;
	END IF;
      ELSE
	RETURN l_discount;
      END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'Get_Invoice_Bal_After_Disc()-' );
  END IF;

  RETURN l_discount;
  EXCEPTION
    WHEN OTHERS THEN
      l_return_status := 'E';
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug( 'l_return_status :- '|| l_return_status );
	arp_standard.debug( 'Exception in Get_Available_Disc_On_Inv()!!!' );
      END IF;
      RAISE;
END get_available_disc_on_inv;



END ARP_DISCOUNTS_API;

/
