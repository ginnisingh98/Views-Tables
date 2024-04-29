--------------------------------------------------------
--  DDL for Package Body ARP_CASHBOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CASHBOOK" AS
/*$Header: ARRECBKB.pls 120.19.12010000.9 2010/06/27 17:31:57 spdixit ship $*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

g_refresh_running VARCHAR2(1);
--
-- Public Procedures
--
PROCEDURE clear(
		p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_actual_value_date	IN DATE,
		p_exchange_date		IN ar_cash_receipt_history.exchange_date%TYPE,
		p_exchange_rate_type	IN ar_cash_receipt_history.exchange_rate_type%TYPE,
		p_exchange_rate		IN ar_cash_receipt_history.exchange_rate%TYPE,
		p_bank_currency		IN ce_bank_accounts.currency_code%TYPE,
		p_amount_cleared	IN ar_cash_receipt_history.amount%TYPE,
		p_amount_factored	IN ar_cash_receipt_history.factor_discount_amount%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
--
/*----------------------------------
   Some notes to use this clear procedure:

   1. The p_amount_cleared and p_amount_factored to be passed in
      should be in the bank currency.

   2. If p_bank_currency <> the currency of the receipt, this
      means the p_bank_currency must be the functional currency,
      In this case, it assumes the following has been
      validated before calling this procedure:

        p_amount_cleared+p_amount_factored =
                          p_exchange_rate * ar_cash_receipts.amount

   3. If p_bank_currency = the currency of the receipt,
      In this case, it assumes the following has been validated
      before calling this procedure:

        p_amount_cleared+p_amount_factored =
                            ar_cash_receipts.amount

 ------------------------------------*/
l_cr_rec		ar_cash_receipts%ROWTYPE;
l_rma_rec		ar_receipt_method_accounts%ROWTYPE;
l_crh_rec_old		ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new		ar_cash_receipt_history%ROWTYPE;
l_dist_rec 		ar_distributions%ROWTYPE;
l_radj_rec 		ar_rate_adjustments%ROWTYPE;
l_acctd_receipt_amt_new ar_cash_receipt_history.acctd_amount%TYPE;
l_acctd_receipt_amt_old ar_cash_receipt_history.acctd_amount%TYPE;
l_cash_amt 		ar_cash_receipt_history.amount%TYPE;
l_acctd_cash_amt 	ar_cash_receipt_history.acctd_amount%TYPE;
l_bank_amt 		ar_cash_receipt_history.factor_discount_amount%TYPE;
l_acctd_bank_amt 	ar_cash_receipt_history.acctd_factor_discount_amount%TYPE;
l_convert_receipt_amt   ar_cash_receipts.amount%TYPE;
--Bug#2750340
l_event_rec             arp_xla_events.xla_events_type;
l_org_id		            number;

l_receipt_number	ar_cash_receipts.receipt_number%TYPE;
l_payment_trxn_extn_id	iby_fndcpt_tx_operations.trxn_extension_id%type;
l_status		BOOLEAN := FALSE;
l_settle_error_message	varchar2(2000);
settlement_pending_raise exception;

l_exchange_rate		ar_cash_receipt_history.exchange_rate%TYPE;
l_exchange_date		ar_cash_receipt_history.exchange_date%TYPE;
l_exchange_rate_type	ar_cash_receipt_history.exchange_rate_type%TYPE;

  /* 9363502 - define tables used by refresh_at_risk_value */
  l_customer_id_tab ar_bus_event_sub_pvt.generic_id_type;
  l_site_use_id_tab ar_bus_event_sub_pvt.generic_id_type;
  l_org_id_tab      ar_bus_event_sub_pvt.generic_id_type;
  l_currency_tab    ar_bus_event_sub_pvt.currency_type;
  /* end 9363502 */

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('clear: ' || 'p_exchange_rate_type = ' || p_exchange_rate_type);
   arp_standard.debug('clear: ' || 'p_exchange_rate = ' || to_char(p_exchange_rate));
   arp_standard.debug('clear: ' || 'p_bank_currency = ' || p_bank_currency);
   arp_standard.debug('p_amount_cleared = ' || to_char(p_amount_cleared));
   arp_standard.debug('clear: ' || 'p_amount_factored = ' || to_char(p_amount_factored));
   arp_standard.debug('p_cr_id:'|| p_cr_id);
   arp_standard.debug('p_trx_date :'||p_trx_date);
   arp_standard.debug('p_gl_date :'||p_gl_date);
   arp_standard.debug('p_actual_value_date :'||p_actual_value_date);

      arp_util.debug( '>>>>>>> arp_cashbook.clear' );
   END IF;

   -- Bug 7443802

   begin
    select org_id into l_org_id
    from ar_cash_receipts_all
    where cash_receipt_id = p_cr_id;

     mo_global.init('AR');
     mo_global.set_policy_context('S',l_org_id);

  exception
     when others then
       arp_standard.debug('Unable to drive the org id for p_cr_id:'|| p_cr_id);
  end;

  -- Bug 7443802 END

   --Setting the Org Context Bug5212892
   ar_mo_global_cache.populate;
   arp_global.init_global(mo_global.get_current_org_id);
   arp_standard.init_standard(mo_global.get_current_org_id);

/* Bug 7828491: Check for settlement status in IBY summaries table.
   Do not allow user to clear the receipt.Raise error if it is still pending.*/

   BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Check for settlement status in IBY table');
   END IF;

	SELECT receipt_number, payment_trxn_extension_id
	into l_receipt_number, l_payment_trxn_extn_id
        FROM ar_cash_receipts
	WHERE cash_receipt_id = p_cr_id ;

        IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('l_receipt_number: '|| l_receipt_number);
	    arp_standard.debug('l_payment_trxn_extn_id: '|| l_payment_trxn_extn_id);
        END IF;

	IF  l_payment_trxn_extn_id is not null then

	BEGIN
            /* Call to check the settlement status of an extension.
               Reusing the function from ARP_REVERSE_RECEIPT doing
               the same. */
	    l_status := ARP_REVERSE_RECEIPT.check_settlement_status(
					l_payment_trxn_extn_id);

	    IF l_status then

	-- Only status = 0 are success cases whose settlement is completed in Payments.
	-- This is an error staus, so error has to be raised.
		IF p_module_name = 'AR_AUTOMATIC_CLEARING' THEN
		-- If call is from AR conc request, put messages in fnd log file
		    FND_MESSAGE.SET_NAME('AR','AR_IBY_SETTLEMENT_PENDING_CLR');
    		    FND_MESSAGE.SET_TOKEN('RECEIPT_NUMBER',l_receipt_number);
		    l_settle_error_message := FND_MESSAGE.GET;
		    fnd_file.put_line(FND_FILE.LOG,l_settle_error_message);

		    l_settle_error_message := 'Extension ID queried is: ' || l_payment_trxn_extn_id;
		    fnd_file.put_line(FND_FILE.LOG,l_settle_error_message);
		ELSE
		-- If call is not from AR conc request, raise FND exception raise.
		    FND_MESSAGE.SET_NAME('AR','AR_IBY_SETTLEMENT_PENDING_CLR');
		    FND_MESSAGE.SET_TOKEN('RECEIPT_NUMBER',l_receipt_number);
		    RAISE settlement_pending_raise;
		END IF;

		RETURN ;
	    END IF;

	EXCEPTION
	  when settlement_pending_raise then
	      raise;
	     WHEN OTHERS THEN
     -- Still raise the error, As the receipt is remitted but no record in IBY table.
	     IF p_module_name = 'AR_AUTOMATIC_CLEARING' THEN
		    FND_MESSAGE.SET_NAME('AR','AR_IBY_SETTLEMENT_PENDING_CLR');
    		    FND_MESSAGE.SET_TOKEN('RECEIPT_NUMBER',l_receipt_number);
		    l_settle_error_message := FND_MESSAGE.GET;
		    fnd_file.put_line(FND_FILE.LOG,l_settle_error_message);

		    l_settle_error_message := 'Extension ID queried is: ' || l_payment_trxn_extn_id;
		    fnd_file.put_line(FND_FILE.LOG,l_settle_error_message);
	     ELSE
		FND_MESSAGE.SET_NAME('AR','AR_IBY_SETTLEMENT_PENDING_CLR');
	        FND_MESSAGE.SET_TOKEN('RECEIPT_NUMBER',l_receipt_number);
	        RAISE settlement_pending_raise;
	     END IF;

	     RETURN ;
	END;

	END IF;

   EXCEPTION
     WHEN settlement_pending_raise then
        RAISE settlement_pending_raise;
     WHEN OTHERS THEN
         IF p_module_name = 'AR_AUTOMATIC_CLEARING' THEN
     		l_settle_error_message := 'Exception while quering cash receipt ID: '|| p_cr_id ;
		fnd_file.put_line(FND_FILE.LOG,l_settle_error_message);
         ELSE
		FND_MESSAGE.SET_NAME('AR','GENERIC_MESSAGE');
		APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
       RETURN ;
   END;

   -- Assume this receipt has already been locked

   -- Validate the GL Date is in open or future period

   -- Validate exchange info is correct : all missing or all provided

   -- Validate the amt_clr +bank_charge = receipt amt
   -- receipt amt * rate = accnt amount

   -- Fetch the history record
   arp_cr_history_pkg.fetch_f_crid( p_cr_id, l_crh_rec_old );

   --Bug8866537
   l_exchange_rate_type  := NVL(p_exchange_rate_type,l_crh_rec_old.exchange_rate_type);
   l_exchange_date	 := trunc(NVL(p_exchange_date,SYSDATE));


   -- check if receipt is reversed.  If yes, raise exception.
   -- (bug 376817)

   IF ( l_crh_rec_old.status = 'REVERSED' ) THEN
         fnd_message.set_name('AR', 'AR_CANNOT_CLEAR_REV_RECEIPT' );
         app_exception.raise_exception;
   END IF;

   -- Fetch the cash receipt record
   l_cr_rec.cash_receipt_id := p_cr_id;
   arp_cash_receipts_pkg.fetch_p( l_cr_rec );


   -- Fetch the receipt method bank account record
   arp_rm_accounts_pkg.fetch_p( l_cr_rec.receipt_method_id,
			     l_cr_rec.remit_bank_acct_use_id,
			     l_rma_rec );

   -- Insert a new history record

   -- Calculate entered amount and acctd amount
   -- If the receipt is functional currency, then amount and
   -- acctd amounts are the same.
   -- If bank currency is the same as the receipt's currency,
   -- then the amount_cleared passed in is in the entered amount.
   -- If bank currency is not the same as the receipt's currency,
   -- then the amount_cleared passed in is in the functional amount.
   l_acctd_receipt_amt_old := l_crh_rec_old.acctd_amount + nvl(L_crh_rec_old.acctd_factor_discount_amount,0);

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('clear: ' || 'l_cr_rec.currency_code = ' || l_cr_rec.currency_code);
   arp_standard.debug('clear: ' || 'ARP_GLOBAL.functional_currency = ' || ARP_GLOBAL.functional_currency);
   arp_standard.debug('clear: ' || 'l_crh_rec_old.exchange_rate = ' || to_char(l_crh_rec_old.exchange_rate));
END IF;

   IF ( l_cr_rec.currency_code = ARP_GLOBAL.functional_currency )
   THEN
	l_acctd_receipt_amt_new := l_cr_rec.amount;
	l_crh_rec_new.amount := p_amount_cleared;
	l_crh_rec_new.acctd_amount := p_amount_cleared;
	l_crh_rec_new.factor_discount_amount := p_amount_factored;
	l_crh_rec_new.acctd_factor_discount_amount := p_amount_factored;
   ELSE
	IF p_bank_currency = l_cr_rec.currency_code
	   THEN
	        IF ( NVL(p_exchange_rate,-1) <> l_crh_rec_old.exchange_rate )
		THEN
	          -- Changes for triangulation: If exchange rate type is not
		  -- user, call GL API to calculate accounted amount

		  -- Bug 925765: instead of l_cr_rec.exchange_rate_type
                  -- (i.e. old rate type) use the new one for comparison
		  -- with 'User'!

		  IF (p_exchange_rate_type IS NOT NULL) AND (p_exchange_rate_type = 'User') THEN
		   	l_acctd_receipt_amt_new := arp_util.functional_amount(
						l_cr_rec.amount,
						ARP_GLOBAL.functional_currency,
						nvl(p_exchange_rate,1),
						NULL,NULL );

			l_exchange_rate := nvl(p_exchange_rate,1);

		  ELSIF (p_exchange_rate_type IS NULL) AND (l_exchange_rate_type = 'User') THEN
		   	l_acctd_receipt_amt_new := arp_util.functional_amount(
						l_cr_rec.amount,
						ARP_GLOBAL.functional_currency,
						nvl(l_crh_rec_old.exchange_rate,1),
						NULL,NULL );

			l_exchange_rate := nvl(l_crh_rec_old.exchange_rate,1);
		  ELSE
			l_acctd_receipt_amt_new := gl_currency_api.convert_amount(
						l_cr_rec.currency_code,
						ARP_GLOBAL.functional_currency,
                                                l_exchange_date,
                                                l_exchange_rate_type,
                                                l_cr_rec.amount);

                        l_exchange_rate := gl_currency_api.get_rate(
						l_cr_rec.currency_code,
						ARP_GLOBAL.functional_currency,
                                                l_exchange_date,
                                                l_exchange_rate_type);
		  END IF;
		ELSE
			l_acctd_receipt_amt_new := l_acctd_receipt_amt_old;

		END IF;

	 	l_crh_rec_new.amount := p_amount_cleared;
		-- Changes for triangulation: If exchange rate type is not
                -- user, call GL API to calculate accounted amount

		  -- Bug 925765: instead of l_cr_rec.exchange_rate_type
                  -- (i.e. old rate type) use the new one for comparison
		  -- with 'User'!

		 IF (p_exchange_rate_type IS NOT NULL) AND (p_exchange_rate_type = 'User') THEN
		  l_crh_rec_new.acctd_amount := arp_util.functional_amount(
					       	p_amount_cleared,
					       	ARP_GLOBAL.functional_currency,
						nvl(p_exchange_rate,1),
						NULL,NULL );

		  l_exchange_rate := nvl(p_exchange_rate,1);

		 ELSIF (p_exchange_rate_type IS NULL) AND (l_exchange_rate_type = 'User') THEN
		  l_crh_rec_new.acctd_amount := arp_util.functional_amount(
					       	p_amount_cleared,
					       	ARP_GLOBAL.functional_currency,
						nvl(l_crh_rec_old.exchange_rate,1),
						NULL,NULL );

                  l_exchange_rate := nvl(l_crh_rec_old.exchange_rate,1);

		ELSE
		  l_crh_rec_new.acctd_amount := gl_currency_api.convert_amount(
                                                l_cr_rec.currency_code,
                                                ARP_GLOBAL.functional_currency,
                                                l_exchange_date,
                                                l_exchange_rate_type,
                                                p_amount_cleared);

		  l_exchange_rate := gl_currency_api.get_rate(
                                                l_cr_rec.currency_code,
                                                ARP_GLOBAL.functional_currency,
                                                l_exchange_date,
                                                l_exchange_rate_type);

		END IF;

		l_crh_rec_new.factor_discount_amount := p_amount_factored;
		l_crh_rec_new.acctd_factor_discount_amount := l_acctd_receipt_amt_new - L_crh_rec_new.acctd_amount;

	   ELSE
	        IF ( NVL(p_exchange_rate,-1) <> l_crh_rec_old.exchange_rate )
		THEN
			l_acctd_receipt_amt_new := p_amount_cleared + p_amount_factored;
		ELSE
			l_acctd_receipt_amt_new := l_acctd_receipt_amt_old;
		END IF;

                -- Bug 646561
                -- Convert the receipt amount to the same currency as the
                -- cleared amount.
		-- Changes for triangulation: If exchange rate type is not
		-- user, call GL API to calculate accounted amount

		  -- Bug 925765: instead of l_cr_rec.exchange_rate_type
                  -- (i.e. old rate type) use the new one for comparison
		  -- with 'User'!

		IF (p_exchange_rate_type IS NOT NULL) AND (p_exchange_rate_type = 'User') THEN
                  l_convert_receipt_amt := arp_util.functional_amount
                                            (l_cr_rec.amount,
                                             ARP_GLOBAL.functional_currency,
                                             NVL(p_exchange_rate,1),null,null);

		  l_exchange_rate := nvl(p_exchange_rate,1);

		ELSIF (p_exchange_rate_type IS NULL) AND (l_exchange_rate_type = 'User') THEN
                  l_convert_receipt_amt := arp_util.functional_amount
                                            (l_cr_rec.amount,
                                             ARP_GLOBAL.functional_currency,
                                             NVL(l_crh_rec_old.exchange_rate,1),null,null);

		  l_exchange_rate := nvl(l_crh_rec_old.exchange_rate,1);

		ELSE
		  l_convert_receipt_amt := gl_currency_api.convert_amount(
						l_cr_rec.currency_code,
						ARP_GLOBAL.functional_currency,
                                                l_exchange_date,
                                                l_exchange_rate_type,
                                                l_cr_rec.amount);

		  l_exchange_rate := gl_currency_api.get_rate(
                                                l_cr_rec.currency_code,
                                                ARP_GLOBAL.functional_currency,
                                                l_exchange_date,
                                                l_exchange_rate_type);
		END IF;

                -- If the converted receipt amount is the same as the cleared
                -- amount then we don't need to calculate a new receipt amount.

                IF l_convert_receipt_amt = p_amount_cleared then

                  l_crh_rec_new.amount := l_cr_rec.amount;

                ELSE

		  -- Changes for triangulation: If exchange rate type is not
		  -- user, call GL API to calculate accounted amount

		  -- Bug 925765: instead of l_cr_rec.exchange_rate_type
                  -- (i.e. old rate type) use the new one for comparison
		  -- with 'User'!

		  IF (p_exchange_rate_type IS NOT NULL) AND (p_exchange_rate_type = 'User') THEN
  		    l_crh_rec_new.amount := arp_util.functional_amount(
		   	       			p_amount_cleared,
					       	l_cr_rec.currency_code,
						1/nvl(p_exchange_rate,1),
						NULL,NULL );

		    l_exchange_rate := 1/nvl(p_exchange_rate,1);

		  ELSIF (p_exchange_rate_type IS NULL) AND (l_exchange_rate_type = 'User') THEN
  		    l_crh_rec_new.amount := arp_util.functional_amount(
		   	       			p_amount_cleared,
					       	l_cr_rec.currency_code,
						1/nvl(l_crh_rec_old.exchange_rate,1),
						NULL,NULL );

		    l_exchange_rate := 1/nvl(l_crh_rec_old.exchange_rate,1);

		  ELSE
		    l_crh_rec_new.amount := gl_currency_api.convert_amount(
						ARP_GLOBAL.functional_currency,
						l_cr_rec.currency_code,
                                                l_exchange_date,
                                                l_exchange_rate_type,
                                                p_amount_cleared);

		    l_exchange_rate := gl_currency_api.get_rate(
    						ARP_GLOBAL.functional_currency,
						l_cr_rec.currency_code,
                                                l_exchange_date,
                                                l_exchange_rate_type);
		  END IF;

                END IF;

		l_crh_rec_new.acctd_amount := p_amount_cleared;
		l_crh_rec_new.factor_discount_amount := l_cr_rec.amount - L_crh_rec_new.amount;
		l_crh_rec_new.acctd_factor_discount_amount := p_amount_factored;
       END IF;
   END IF;

   IF ( p_exchange_date = l_crh_rec_old.exchange_date ) OR
      ( (p_exchange_date IS NULL) AND (l_crh_rec_old.exchange_date IS NULL) )
   THEN
      l_crh_rec_new.exchange_date := l_crh_rec_old.exchange_date;
   ELSE
      l_crh_rec_new.exchange_date := l_exchange_date;
   END IF;

   IF ( p_exchange_rate = l_crh_rec_old.exchange_rate ) OR
      ( (p_exchange_rate IS NULL) AND (l_crh_rec_old.exchange_rate IS NULL) )
   THEN
      l_crh_rec_new.exchange_rate := l_crh_rec_old.exchange_rate;
   ELSE
      l_crh_rec_new.exchange_rate := l_exchange_rate;
   END IF;

   IF ( p_exchange_rate_type = l_crh_rec_old.exchange_rate_type ) OR
      ( (p_exchange_rate_type IS NULL) AND (l_crh_rec_old.exchange_rate_type IS NULL) )
   THEN
      l_crh_rec_new.exchange_rate_type := l_crh_rec_old.exchange_rate_type;
   ELSE
      l_crh_rec_new.exchange_rate_type := l_exchange_rate_type;
   END IF;

   --  11.5 VAT changes:
   --  modified to get the conversion information from the cash receipt history
   --  record.
   l_dist_rec.currency_code            := l_cr_rec.currency_code;
   l_dist_rec.currency_conversion_rate := l_crh_rec_new.exchange_rate;
   l_dist_rec.currency_conversion_type := l_crh_rec_new.exchange_rate_type;
   l_dist_rec.currency_conversion_date := l_crh_rec_new.exchange_date;
   l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
   l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;

   l_crh_rec_new.cash_receipt_id := p_cr_id;
   l_crh_rec_new.status := 'CLEARED';
   l_crh_rec_new.trx_date := p_trx_date;
   l_crh_rec_new.first_posted_record_flag := 'N';
   l_crh_rec_new.postable_flag := 'Y';
   l_crh_rec_new.factor_flag := l_crh_rec_old.factor_flag;
   l_crh_rec_new.gl_date := p_gl_date;
   l_crh_rec_new.current_record_flag := 'Y';

   l_crh_rec_new.batch_id := l_crh_rec_old.batch_id;
-- fix for bug # 766382
-- populating batch_id in ar_cash_receipt_history table
-- with the batch_id of the remittance record.
-- l_crh_rec_new.batch_id := NULL;

   l_crh_rec_new.account_code_combination_id := l_rma_rec.cash_ccid;

   l_crh_rec_new.reversal_gl_date := NULL;
   l_crh_rec_new.reversal_cash_receipt_hist_id := NULL;

   l_crh_rec_new.bank_charge_account_ccid := l_rma_rec.bank_charges_ccid;
   l_crh_rec_new.posting_control_id := -3;
   l_crh_rec_new.reversal_posting_control_id := NULL;
   l_crh_rec_new.gl_posted_date := NULL;
   l_crh_rec_new.reversal_gl_posted_date := NULL;
   IF (l_crh_rec_old.status = 'CLEARED' )
   THEN
      l_crh_rec_new.prv_stat_cash_receipt_hist_id := l_crh_rec_old.prv_stat_cash_receipt_hist_id;
   ELSE
      l_crh_rec_new.prv_stat_cash_receipt_hist_id := l_crh_rec_old.cash_receipt_history_id;
   END IF;
   l_crh_rec_new.created_from := substrb(p_module_name||'ARP_CASHBOOK.CLEAR',1,30);
   l_crh_rec_new.reversal_created_from := NULL;
   arp_cr_history_pkg.insert_p( l_crh_rec_new, l_crh_rec_new.cash_receipt_history_id );

   -- Update the old history record
   l_crh_rec_old.current_record_flag := NULL;
   l_crh_rec_old.reversal_gl_date := p_gl_date;
   l_crh_rec_old.reversal_cash_receipt_hist_id := l_crh_rec_new.cash_receipt_history_id;
   l_crh_rec_old.reversal_posting_control_id := -3;
   l_crh_rec_old.reversal_created_from := substrb(p_module_name||'ARP_CASHBOOK.CLEAR',1,30);
   arp_cr_history_pkg.update_p( l_crh_rec_old );

--Bug#2750340
--{BUG#5051143 - the cash book call is document based not request based
--    l_event_rec.xla_req_id      := arp_global.request_id;
--    l_event_rec.xla_mode        := 'B';
--}
    l_event_rec.xla_from_doc_id := p_cr_id;
    l_event_rec.xla_to_doc_id   := p_cr_id;
    l_event_rec.xla_doc_table   := 'CRH';
    l_event_rec.xla_mode        := 'O';
    l_event_rec.xla_call        := 'B';
    arp_xla_events.Create_Events(p_xla_ev_rec => l_event_rec );

   -- Insert the cash account ar_distributions record
------------------------------------------------------------------------------------
-- Removed the following 'if' as part of bug fix 868448
-- because we should be able to create zero dollar misc receipts and later clear them.
-- Because of this if, records are never created in ar_distributions and as a result
-- gl_transfer does'nt pick up these records to post
-----------------------------------------------------------------------------------
   --IF ( l_crh_rec_new.amount <>0 ) OR
   --   ( l_crh_rec_new.acctd_amount <> 0 )
   --THEN
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'CASH';

      IF ( l_crh_rec_old.status = 'REMITTED' )
      THEN
         l_dist_rec.code_combination_id := l_rma_rec.cash_ccid;
	 l_cash_amt := l_crh_rec_new.amount;
	 l_acctd_cash_amt := l_crh_rec_new.acctd_amount;
      ELSE
	 arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'CASH', l_rma_rec,
				l_dist_rec.code_combination_id);

	 l_cash_amt := l_crh_rec_new.amount - L_crh_rec_old.amount;
	 l_acctd_cash_amt := l_crh_rec_new.acctd_amount - L_crh_rec_old.acctd_amount;
      END IF;

      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_cash_amt < 0 )
      THEN
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.amount_cr := -l_cash_amt;
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_cash_amt;
      ELSE
         l_dist_rec.amount_dr := l_cash_amt;
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := l_acctd_cash_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
/*
      IF ( l_acctd_cash_amt < 0 )
      THEN
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_cash_amt;
      ELSE
         l_dist_rec.acctd_amount_dr := l_acctd_cash_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

   -- Bug 2580219: reinitialize variables for MRC use only.
      l_dist_rec.source_id := l_crh_rec_old.cash_receipt_history_id;
      l_dist_rec.source_table_secondary := 'MRC';
      l_dist_rec.source_id_secondary := l_crh_rec_new.cash_receipt_history_id;

     /* need to insert records into the MRC table.  Calling new
        mrc engine */
/*
       ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);
*/
   -- Bug 2580219 reset the values after the call.. just incase they were used.
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table_secondary := NULL;
      l_dist_rec.source_id_secondary := NULL;

   --END IF;

   -- insert the remittance account ar_distributions record

   /* Bug No. 3644849 JVARKEY */
   -- For Remittance Row The exchange parameters must be as that of its history
   IF ( l_crh_rec_old.status = 'REMITTED' )
   THEN

      l_dist_rec.currency_conversion_rate := l_crh_rec_old.exchange_rate;
      l_dist_rec.currency_conversion_type := l_crh_rec_old.exchange_rate_type;
      l_dist_rec.currency_conversion_date := l_crh_rec_old.exchange_date;

   END IF;

   IF ( l_crh_rec_old.status = 'REMITTED' ) AND
      ( l_crh_rec_old.factor_flag <> 'Y' ) -- AND
/* skoukunt: comment to Fix bug 1198295
      (( l_crh_rec_old.amount <>0 ) OR
       ( l_crh_rec_old.acctd_amount <> 0 ))
*/
   THEN
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'REMITTANCE';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'REMITTANCE', l_rma_rec,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_cr_rec.amount < 0 )
      THEN
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.amount_dr := -l_cr_rec.amount;
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt_old;
      ELSE
         l_dist_rec.amount_cr := l_cr_rec.amount;
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt_old;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
/*
      IF ( l_acctd_receipt_amt_old < 0 )
      THEN
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt_old;
      ELSE
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt_old;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

     /* need to insert records into the MRC table.  Calling new
        mrc engine */
/*
      ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);
*/
   END IF;
   /*4401288 New Exchange rate,type and date needs to be passed for new records*/
   IF ( l_crh_rec_old.status = 'REMITTED' )
   THEN

      l_dist_rec.currency_conversion_rate := l_crh_rec_new.exchange_rate;
      l_dist_rec.currency_conversion_type := l_crh_rec_new.exchange_rate_type;
      l_dist_rec.currency_conversion_date := l_crh_rec_new.exchange_date;

   END IF;

   -- insert the short term debt account ar_distributions record
   IF ( l_crh_rec_old.status = 'REMITTED' ) AND
      ( l_crh_rec_old.factor_flag ='Y' ) -- AND
/* skoukunt: comment to Fix bug 1198295
      (( l_crh_rec_old.amount <>0 ) OR
      ( l_crh_rec_old.acctd_amount <> 0 ))
*/
   THEN
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'SHORT_TERM_DEBT';
      l_dist_rec.code_combination_id := l_rma_rec.short_term_debt_ccid;
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_cr_rec.amount < 0 )
      THEN
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.amount_dr := -l_cr_rec.amount;
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt_new;
      ELSE
         l_dist_rec.amount_cr := l_cr_rec.amount;
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt_new;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
/*
      IF ( l_acctd_receipt_amt_new < 0 )
      THEN
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt_new;
      ELSE
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt_new;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
*/

      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

     /* need to insert records into the MRC table.  Calling new
        mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

   END IF;

   -- insert the factor account ar_distributions record if it's
   -- factor='Y' and there's a rate adj involved
   IF ( l_crh_rec_old.factor_flag = 'Y' ) AND
      ( l_crh_rec_old.exchange_rate <> l_crh_rec_new.exchange_rate ) AND
      ( (l_acctd_receipt_amt_new - l_acctd_receipt_amt_old) <> 0 )
   THEN
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'FACTOR';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'FACTOR', l_rma_rec,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( (l_acctd_receipt_amt_new - l_acctd_receipt_amt_old) < 0 )
      THEN
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.amount_cr := 0;
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -(l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
      ELSE
         l_dist_rec.amount_dr := 0;
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := (l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
/*
      IF ( (l_acctd_receipt_amt_new - l_acctd_receipt_amt_old) < 0 )
      THEN
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -(l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
      ELSE
         l_dist_rec.acctd_amount_dr := (l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
*/

      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

   END IF;

   -- insert the short term debt ar_distributions record if it's
   -- factor='Y' and there's a rate adj involved and it's
   -- prior history record is 'CLEARED'
   IF ( l_crh_rec_old.factor_flag = 'Y' ) AND
      ( l_crh_rec_old.status = 'CLEARED' ) AND
      ( l_crh_rec_old.exchange_rate <> l_crh_rec_new.exchange_rate ) AND
      ( (l_acctd_receipt_amt_new - l_acctd_receipt_amt_old) <> 0 )
   THEN
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'SHORT_TERM_DEBT';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'SHORT_TERM_DEBT', l_rma_rec,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( (l_acctd_receipt_amt_new - l_acctd_receipt_amt_old) < 0 )
      THEN
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.amount_dr := 0;
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -(l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
      ELSE
         l_dist_rec.amount_cr := 0;
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := (l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
/*
      IF ( (l_acctd_receipt_amt_new - l_acctd_receipt_amt_old) < 0 )
      THEN
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -(l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
      ELSE
         l_dist_rec.acctd_amount_cr := (l_acctd_receipt_amt_new - L_acctd_receipt_amt_old);
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
*/

      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

   END IF;

   -- insert the bank charge account ar_distributions record
   IF ( l_crh_rec_new.factor_discount_amount <>0 ) OR
      ( l_crh_rec_new.acctd_factor_discount_amount <> 0 )
   THEN
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'BANK_CHARGES';

      IF ( l_crh_rec_old.status = 'REMITTED' )
      THEN
         l_dist_rec.code_combination_id := l_crh_rec_new.bank_charge_account_ccid;
	 l_bank_amt := nvl(l_crh_rec_new.factor_discount_amount,0);
	 l_acctd_bank_amt := nvl(l_crh_rec_new.acctd_factor_discount_amount,0);
      ELSE
	 arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'BANK_CHARGES', l_rma_rec,
				l_dist_rec.code_combination_id);
	 l_bank_amt := nvl(l_crh_rec_new.factor_discount_amount,0) - nvl(L_crh_rec_old.factor_discount_amount,0);
	 l_acctd_bank_amt := nvl(l_crh_rec_new.acctd_factor_discount_amount,0) - nvl(L_crh_rec_old.acctd_factor_discount_amount,0);
      END IF;

      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_bank_amt < 0 )
      THEN
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.amount_cr := -l_bank_amt;
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_bank_amt;
      ELSE
         l_dist_rec.amount_dr := l_bank_amt;
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := l_acctd_bank_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
/*
      IF ( l_acctd_bank_amt < 0 )
      THEN
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_bank_amt;
      ELSE
         l_dist_rec.acctd_amount_dr := l_acctd_bank_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

     /* need to insert records into the MRC table.  Calling new
        mrc engine */

     ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

   END IF;

   -- If exchange rate has been changed
   -- Insert a record into ar_rate_adjustments
   -- Call arplbrad.main() to take care the ar_cash_receipts, ar_payment_schedules
   -- and ar_receivable_applications/ar_misc_cash_distributions
   --
   -- 17-MAY-1999 J Rautiainen truncation exits on exchange rate so the comparison
   -- was changed from comparing exchange rates to comparing accounted amounts in order
   -- to fix bug 874052.
   -- Commented out NOCOPY for bug fix 874052 IF ( l_crh_rec_old.exchange_rate <> l_crh_rec_new.exchange_rate )
   IF ( (l_crh_rec_old.acctd_amount + NVL(l_crh_rec_old.acctd_factor_discount_amount,0) )
        <> (l_crh_rec_new.acctd_amount + NVL(l_crh_rec_new.acctd_factor_discount_amount,0)))
   THEN
      l_radj_rec.cash_receipt_id := p_cr_id;
      l_radj_rec.gain_loss := arp_util.functional_amount(
					       	l_cr_rec.amount,
					       	ARP_GLOBAL.functional_currency,
						(l_crh_rec_new.exchange_rate - l_crh_rec_old.exchange_rate),
						NULL,NULL );
      l_radj_rec.gl_date := p_gl_date;
      l_radj_rec.new_exchange_date := l_crh_rec_new.exchange_date;
      l_radj_rec.new_exchange_rate := l_crh_rec_new.exchange_rate;
      l_radj_rec.new_exchange_rate_type:= l_crh_rec_new.exchange_rate_type ;
      l_radj_rec.old_exchange_date := l_crh_rec_old.exchange_date;
      l_radj_rec.old_exchange_rate := l_crh_rec_old.exchange_rate;
      l_radj_rec.old_exchange_rate_type:= l_crh_rec_old.exchange_rate_type;
      l_radj_rec.gl_posted_date := NULL;
      l_radj_rec.posting_control_id := -3;
      l_radj_rec.created_from := substrb(p_module_name||'ARP_CASHBOOK.CLEAR',1,30);
      arp_rate_adjustments_pkg.insert_p( l_radj_rec,l_radj_rec.rate_adjustment_id  );

      arp_rate_adj.main(
			p_cr_id,
			l_radj_rec.new_exchange_date,
			l_radj_rec.new_exchange_rate,
			l_radj_rec.new_exchange_rate_type,
			l_radj_rec.gl_date,
			ARP_GLOBAL.created_by,
			ARP_GLOBAL.creation_date,
			ARP_GLOBAL.last_updated_by,
			ARP_GLOBAL.last_update_date,
			ARP_GLOBAL.last_update_login,
			FALSE,
			l_crh_rec_new.cash_receipt_history_id
			);

   END IF;


  -- Insert value date into CR record

  UPDATE AR_CASH_RECEIPTS
  SET actual_value_date = p_actual_value_date,
      rec_version_number =  nvl(rec_version_number,1)+1 /* bug 3372585 */
  WHERE cash_receipt_id = p_cr_id;

   -- Populate OUT NOCOPY parameters
   p_crh_id := l_crh_rec_new.cash_receipt_history_id;

   /* 9363502 - set receipt_at_risk_value in ar_trx_val_summary
      for regular and misc receipts */
   IF l_cr_rec.pay_from_customer IS NOT NULL
   THEN

      /* Check for REFRESH running first */
      IF g_refresh_running IS NULL
      THEN
         BEGIN
            select 'Y'
            into   g_refresh_running
            from   ar_conc_process_requests
            where  concurrent_program_name = 'ARSUMREF';
         EXCEPTION
           WHEN OTHERS THEN
              g_refresh_running := 'N';
         END;
      END IF;

      IF g_refresh_running = 'N'
      THEN

         /* 9363502 - Set receipt_at_risk_value in ar_trx_bal_summary */
         l_customer_id_tab(0) := l_cr_rec.pay_from_customer;
         l_site_use_id_tab(0) := NVL(l_cr_rec.customer_site_use_id,-99);
         l_currency_tab(0) :=    l_cr_rec.currency_code;
         l_org_id_tab(0) :=      l_org_id;

         ar_bus_event_sub_pvt.refresh_at_risk_value(l_customer_id_tab,
                                                    l_site_use_id_tab,
                                                    l_currency_tab,
                                                    l_org_id_tab);
      END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('  g_refresh_running = ' || g_refresh_running);
      arp_util.debug( '<<<<<<< arp_cashbook.clear' );
   END IF;

EXCEPTION
     WHEN settlement_pending_raise then
	APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_util.debug( 'EXCEPTION: ARP_CASHBOOK.clear' );
	  END IF;
          RAISE;

END clear;

PROCEDURE unclear(
		p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_actual_value_date	IN ar_cash_receipts.actual_value_date%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
--
l_cr_rec	ar_cash_receipts%ROWTYPE;
l_crh_rec_prv_stat ar_cash_receipt_history%ROWTYPE;
l_crh_rec_fr_radj	ar_cash_receipt_history%ROWTYPE;
l_crh_rec_prv_stat_cash ar_cash_receipt_history%ROWTYPE;
l_crh_rec_old	ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new	ar_cash_receipt_history%ROWTYPE;
l_rma_rec	ar_receipt_method_accounts%ROWTYPE;
l_radj_rec      ar_rate_adjustments%ROWTYPE;
l_dist_rec ar_distributions%ROWTYPE;
l_receipt_amt ar_cash_receipt_history.amount%TYPE;
l_acctd_receipt_amt ar_cash_receipt_history.acctd_amount%TYPE;
l_new_crh_id_fr_radj ar_cash_receipt_history.cash_receipt_history_id%TYPE;

l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '>>>>>>> arp_cashbook.unclear' );
   END IF;


   --Setting the Org Context Bug5212892
   ar_mo_global_cache.populate;
   arp_global.init_global(mo_global.get_current_org_id);
   arp_standard.init_standard(mo_global.get_current_org_id);


   -- Assume this receipt has already been locked

   -- Validate the GL Date is in open or future period

   -- Fetch the history record
   arp_cr_history_pkg.fetch_f_crid( p_cr_id, l_crh_rec_old );

   -- Check if this receipt has already been reversed or unclear, then
   -- fail and give an error message
   IF ( l_crh_rec_old.status = 'REVERSED')
   	THEN
        	fnd_message.set_name('AR', 'AR_CANNOT_UNCLEAR_REV_RECEIPT' );
 	 	app_exception.raise_exception;
   	ELSE
		IF ( l_crh_rec_old.status <> 'CLEARED' )
   		THEN
        		fnd_message.set_name('AR', 'AR_RECEIPT_CANNOT_UNCLEAR' );
         		app_exception.raise_exception;
   		END IF;
   END IF;
   -- make sure the receipt was not created as CLEARED
   -- (in that case there is no previous state, and we return to caller
   -- without error (see Bug 305482)):

   IF ( l_crh_rec_old.prv_stat_cash_receipt_hist_id IS NOT NULL )
   THEN

     -- Fetch the history record of the prv status
     arp_cr_history_pkg.fetch_p( l_crh_rec_old.prv_stat_cash_receipt_hist_id, l_crh_rec_prv_stat );

     /*Bug 9761480 Fetch the CLEARED row that is reversal of the previous status REMITTED row */
     arp_cr_history_pkg.fetch_p( l_crh_rec_prv_stat.reversal_cash_receipt_hist_id, l_crh_rec_prv_stat_cash );

     -- Fetch the cash receipt record
     l_cr_rec.cash_receipt_id := p_cr_id;
     arp_cash_receipts_pkg.fetch_p( l_cr_rec );

     --  11.5 VAT changes:
     l_dist_rec.currency_code            := l_cr_rec.currency_code;
     l_dist_rec.currency_conversion_rate := l_crh_rec_old.exchange_rate;
     l_dist_rec.currency_conversion_type := l_crh_rec_old.exchange_rate_type;
     l_dist_rec.currency_conversion_date := l_crh_rec_old.exchange_date;
     l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
     l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;

     -- Fetch the receipt method bank account record
     arp_rm_accounts_pkg.fetch_p( l_cr_rec.receipt_method_id,
			     l_cr_rec.remit_bank_acct_use_id,
			     l_rma_rec );


     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('unclear: ' || 'crh_id_old: ' || to_char(l_crh_rec_old.cash_receipt_history_id));
        arp_standard.debug('unclear: ' || 'crh_id_prv_stat: ' || to_char(l_crh_rec_prv_stat.cash_receipt_history_id));
     END IF;

    /* Bug 9761480 : First revert all the rate adjustments done on Clear receipt.
       Then create the REMITTED row. */
     -- This is a fix to conform to the old 10.5 design,when
     -- you unclear a row, it should retain the same exchange rate as
     -- the original remitted row.
     -- So, if the rate of the cleared row is different from the original
     -- remitted row, then we do a rate adjustment to adjust the exchange rate
     -- back to it's old rate comes from the remitted row.
     l_new_crh_id_fr_radj := NULL;

     -- 17-MAY-1999 J Rautiainen truncation exits on exchange rate so the comparison
     -- was changed from comparing exchange rates to comparing accounted amounts in order
     -- to fix bug 874052.
     -- Commented out NOCOPY for bugfix 874052 IF ( nvl(l_crh_rec_prv_stat.exchange_rate,1) <> nvl(l_crh_rec_new.exchange_rate,1))

     IF ( (nvl(l_crh_rec_prv_stat.acctd_amount,1) + NVL(l_crh_rec_prv_stat.acctd_factor_discount_amount,0) )
          <> (nvl(l_crh_rec_old.acctd_amount,1) + NVL(l_crh_rec_old.acctd_factor_discount_amount,0)))
     THEN
        l_radj_rec.cash_receipt_id := p_cr_id;
        l_radj_rec.gain_loss := arp_util.functional_amount(
					       	l_cr_rec.amount,
					       	ARP_GLOBAL.functional_currency,
						(l_crh_rec_prv_stat.exchange_rate - l_crh_rec_old.exchange_rate),
						NULL,NULL );
        l_radj_rec.gl_date := p_gl_date;
        l_radj_rec.new_exchange_date := l_crh_rec_prv_stat.exchange_date;
        l_radj_rec.new_exchange_rate := l_crh_rec_prv_stat.exchange_rate;
        l_radj_rec.new_exchange_rate_type := l_crh_rec_prv_stat.exchange_rate_type ;
        l_radj_rec.old_exchange_date := l_crh_rec_old.exchange_date;
        l_radj_rec.old_exchange_rate := l_crh_rec_old.exchange_rate;
        l_radj_rec.old_exchange_rate_type:= l_crh_rec_old.exchange_rate_type;
        l_radj_rec.gl_posted_date := NULL;
        l_radj_rec.posting_control_id := -3;
        l_radj_rec.created_from := substrb(p_module_name||'ARP_CASHBOOK.UNCLEAR',1,30);
        arp_rate_adjustments_pkg.insert_p( l_radj_rec,l_radj_rec.rate_adjustment_id  );

        arp_rate_adj.main(
			p_cr_id,
	  		l_radj_rec.new_exchange_date,
			l_radj_rec.new_exchange_rate,
			l_radj_rec.new_exchange_rate_type,
			l_radj_rec.gl_date,
			ARP_GLOBAL.created_by,
			ARP_GLOBAL.creation_date,
			ARP_GLOBAL.last_updated_by,
			ARP_GLOBAL.last_update_date,
			ARP_GLOBAL.last_update_login,
			TRUE,       -- should this be FALSE??? OS 7/6/99
			l_new_crh_id_fr_radj
			);

     END IF;

     -- Insert a new history record
     l_receipt_amt := l_crh_rec_old.amount + nvl(L_crh_rec_old.factor_discount_amount,0);
     l_acctd_receipt_amt := l_crh_rec_prv_stat.acctd_amount + nvl(l_crh_rec_prv_stat.acctd_factor_discount_amount,0);
     l_crh_rec_new.amount := l_crh_rec_prv_stat.amount;
     l_crh_rec_new.factor_discount_amount := l_crh_rec_prv_stat.factor_discount_amount;
     -- Changes for triangulation: If exchange rate type is not
     -- user, call GL API to calculate accounted amount

     -- Bug 925765: gl api was called with 'User' when it shouldn't be.
     -- Problem was that IF statement compared l_crh_rec_old.exchange_rate_type
     -- with 'User', but then we're really going to use the earlier value from
     -- l_crh_rec_prv_stat.exchange_rate_type.

     IF (l_crh_rec_prv_stat.exchange_rate_type = 'User') THEN
       l_crh_rec_new.acctd_amount := arp_util.functional_amount(
						l_crh_rec_prv_stat.amount,
						ARP_GLOBAL.functional_currency,
						nvl(l_crh_rec_prv_stat.exchange_rate,1),
						NULL,NULL );
     ELSE
       l_crh_rec_new.acctd_amount := gl_currency_api.convert_amount(
					l_cr_rec.currency_code,
					ARP_GLOBAL.functional_currency,
					l_crh_rec_prv_stat.exchange_date,
					l_crh_rec_prv_stat.exchange_rate_type,
					l_crh_rec_prv_stat.amount);
     END IF;

     l_crh_rec_new.acctd_factor_discount_amount := l_acctd_receipt_amt - L_crh_rec_new.acctd_amount;

     -- Bug 925765: we were using the exchange rate, date, and type from
     -- the l_crh_rec_old record, but we should have used the values from
     -- the l_crh_rec_prv_stat record, since we're going back to that status.

     l_crh_rec_new.exchange_date := l_crh_rec_prv_stat.exchange_date;
     l_crh_rec_new.exchange_rate := l_crh_rec_prv_stat.exchange_rate;
     l_crh_rec_new.exchange_rate_type := l_crh_rec_prv_stat.exchange_rate_type;
     l_crh_rec_new.cash_receipt_id := p_cr_id;
     l_crh_rec_new.status := l_crh_rec_prv_stat.status;
     l_crh_rec_new.trx_date := p_trx_date;
     l_crh_rec_new.first_posted_record_flag := 'N';
     l_crh_rec_new.postable_flag := 'Y';
     l_crh_rec_new.factor_flag := l_crh_rec_old.factor_flag;
     l_crh_rec_new.gl_date := p_gl_date;
     l_crh_rec_new.current_record_flag := 'Y';
     l_crh_rec_new.batch_id := l_crh_rec_prv_stat.batch_id;
     IF ( l_crh_rec_old.factor_flag = 'Y' )
     THEN
        arp_cr_util.get_dist_ccid( l_crh_rec_prv_stat.cash_receipt_id,
				'CRH', 'FACTOR', l_rma_rec,
				l_crh_rec_new.account_code_combination_id);
     ELSE
      arp_cr_util.get_dist_ccid( l_crh_rec_prv_stat.cash_receipt_id,
				'CRH', 'REMITTANCE', l_rma_rec,
				l_crh_rec_new.account_code_combination_id);
     END IF;
     l_crh_rec_new.reversal_gl_date := NULL;
     l_crh_rec_new.reversal_cash_receipt_hist_id := NULL;
     arp_cr_util.get_dist_ccid( l_crh_rec_prv_stat.cash_receipt_id,
				'CRH', 'BANK_CHARGES', l_rma_rec,
				l_crh_rec_new.bank_charge_account_ccid);
     l_crh_rec_new.posting_control_id := -3;
     l_crh_rec_new.reversal_posting_control_id := NULL;
     l_crh_rec_new.gl_posted_date := NULL;
     l_crh_rec_new.reversal_gl_posted_date := NULL;
     l_crh_rec_new.prv_stat_cash_receipt_hist_id := l_crh_rec_prv_stat.prv_stat_cash_receipt_hist_id;
     l_crh_rec_new.created_from := substrb(p_module_name||'ARP_CASHBOOK.UNCLEAR',1,30);
     l_crh_rec_new.reversal_created_from := NULL;
     arp_cr_history_pkg.insert_p( l_crh_rec_new, l_crh_rec_new.cash_receipt_history_id );

     /* Bug 9761480 : If rate adjustment is reversed, then update those CRH records also*/
     IF l_new_crh_id_fr_radj IS NOT NULL THEN
	-- Update the old history record
	l_crh_rec_old.current_record_flag := NULL;
	l_crh_rec_old.reversal_gl_date := p_gl_date;
	l_crh_rec_old.reversal_cash_receipt_hist_id := l_new_crh_id_fr_radj;
	l_crh_rec_old.reversal_posting_control_id := -3;
	l_crh_rec_old.reversal_created_from := substrb(p_module_name||'ARP_CASHBOOK.UNCLEAR',1,30);
	arp_cr_history_pkg.update_p( l_crh_rec_old );

	/* Fetch newly created Rate Adjustment records */
	arp_cr_history_pkg.fetch_p( l_new_crh_id_fr_radj, l_crh_rec_fr_radj );

	l_crh_rec_fr_radj.current_record_flag := NULL;
	l_crh_rec_fr_radj.reversal_gl_date := p_gl_date;
	l_crh_rec_fr_radj.reversal_cash_receipt_hist_id := l_crh_rec_new.cash_receipt_history_id;
	l_crh_rec_fr_radj.reversal_posting_control_id := -3;
	l_crh_rec_fr_radj.reversal_created_from := substrb(p_module_name||'ARP_CASHBOOK.UNCLEAR',1,30);
	arp_cr_history_pkg.update_p( l_crh_rec_fr_radj );

     ELSE
	l_crh_rec_old.current_record_flag := NULL;
	l_crh_rec_old.reversal_gl_date := p_gl_date;
	l_crh_rec_old.reversal_cash_receipt_hist_id := l_crh_rec_new.cash_receipt_history_id;
	l_crh_rec_old.reversal_posting_control_id := -3;
	l_crh_rec_old.reversal_created_from := substrb(p_module_name||'ARP_CASHBOOK.UNCLEAR',1,30);
	arp_cr_history_pkg.update_p( l_crh_rec_old );

     END IF;

--BUG#5569338
    l_xla_ev_rec.xla_from_doc_id := p_cr_id;
    l_xla_ev_rec.xla_to_doc_id   := p_cr_id;
    l_xla_ev_rec.xla_doc_table   := 'CRH';
    l_xla_ev_rec.xla_mode        := 'O';
    l_xla_ev_rec.xla_call        := 'B';
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);



     -- Insert the remittance/short_term_debt account ar_distributions record
/* skoukunt: comment to Fix bug 1198295
     IF ( l_receipt_amt <>0 ) OR
        ( l_acctd_receipt_amt <> 0 )
     THEN
*/
        l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
        l_dist_rec.source_table := 'CRH';
        IF ( l_crh_rec_old.factor_flag = 'Y' )
        THEN
           l_dist_rec.source_type := 'SHORT_TERM_DEBT';
	   arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'SHORT_TERM_DEBT', l_rma_rec,
				l_dist_rec.code_combination_id);
        ELSE
           l_dist_rec.source_type := 'REMITTANCE';
    	   arp_cr_util.get_dist_ccid( l_crh_rec_prv_stat.cash_receipt_id,
				'CRH', 'REMITTANCE', l_rma_rec,
				l_dist_rec.code_combination_id);
        END IF;

      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
        IF ( l_receipt_amt < 0 )
        THEN
           l_dist_rec.amount_dr := NULL;
           l_dist_rec.amount_cr := -l_receipt_amt;
           l_dist_rec.acctd_amount_dr := NULL;
           l_dist_rec.acctd_amount_cr := -l_acctd_receipt_amt;
        ELSE
           l_dist_rec.amount_dr := l_receipt_amt;
           l_dist_rec.amount_cr := NULL;
           l_dist_rec.acctd_amount_dr := l_acctd_receipt_amt;
           l_dist_rec.acctd_amount_cr := NULL;
        END IF;
/*
        IF ( l_acctd_receipt_amt < 0 )
        THEN
           l_dist_rec.acctd_amount_dr := NULL;
           l_dist_rec.acctd_amount_cr := -l_acctd_receipt_amt;
        ELSE
           l_dist_rec.acctd_amount_dr := l_acctd_receipt_amt;
           l_dist_rec.acctd_amount_cr := NULL;
        END IF;
*/
        arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

--     END IF;

     -- Insert the cash account ar_distributions record
/* skoukunt: comment to Fix bug 1198295
     IF ( l_crh_rec_old.amount <>0 ) OR
        ( l_crh_rec_old.acctd_amount <> 0 )
     THEN
*/

/* Bug 9761480: Since we have reverted the Rate Adjustment if any exists on CASH record.
   So while reversing receipt back to REMITTED status, we will consider CLEARED row
   which is a pair of original remitted row to get the amounts bucket.
   Data is already fetched in variable l_crh_rec_prv_stat_cash */

        l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
        l_dist_rec.source_table := 'CRH';
        l_dist_rec.source_type := 'CASH';
        arp_cr_util.get_dist_ccid( l_crh_rec_prv_stat_cash.cash_receipt_id,
				'CRH', 'CASH', l_rma_rec,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
        IF ( l_crh_rec_prv_stat_cash.amount < 0 )
        THEN
           l_dist_rec.amount_cr := NULL;
           l_dist_rec.amount_dr := -l_crh_rec_prv_stat_cash.amount;
           l_dist_rec.acctd_amount_cr := NULL;
           l_dist_rec.acctd_amount_dr := -l_crh_rec_prv_stat_cash.acctd_amount;
        ELSE
           l_dist_rec.amount_cr := l_crh_rec_prv_stat_cash.amount;
           l_dist_rec.amount_dr := NULL;
           l_dist_rec.acctd_amount_cr := l_crh_rec_prv_stat_cash.acctd_amount;
           l_dist_rec.acctd_amount_dr := NULL;
        END IF;
/*
        IF ( l_crh_rec_old.acctd_amount < 0 )
        THEN
           l_dist_rec.acctd_amount_cr := NULL;
           l_dist_rec.acctd_amount_dr := -l_crh_rec_old.acctd_amount;
        ELSE
           l_dist_rec.acctd_amount_cr := l_crh_rec_old.acctd_amount;
           l_dist_rec.acctd_amount_dr := NULL;
        END IF;
*/
        arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );


--     END IF;

     -- Insert the bank charge account ar_distributions record
     IF ( NVL(l_crh_rec_old.factor_discount_amount,0) <>0 ) OR
        ( NVL(l_crh_rec_old.acctd_factor_discount_amount,0) <> 0 )
     THEN
        l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
        l_dist_rec.source_table := 'CRH';
        l_dist_rec.source_type := 'BANK_CHARGES';
        arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
	  			'CRH', 'BANK_CHARGES', l_rma_rec,
				l_dist_rec.code_combination_id);

      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
        IF ( l_crh_rec_old.factor_discount_amount < 0 )
        THEN
           l_dist_rec.amount_cr := NULL;
           l_dist_rec.amount_dr := -l_crh_rec_old.factor_discount_amount;
           l_dist_rec.acctd_amount_cr := NULL;
           l_dist_rec.acctd_amount_dr := -l_crh_rec_old.acctd_factor_discount_amount;
        ELSE
           l_dist_rec.amount_cr := l_crh_rec_old.factor_discount_amount;
           l_dist_rec.amount_dr := NULL;
           l_dist_rec.acctd_amount_cr := l_crh_rec_old.acctd_factor_discount_amount;
           l_dist_rec.acctd_amount_dr := NULL;
        END IF;
/*
        IF ( l_crh_rec_old.acctd_factor_discount_amount < 0 )
        THEN
           l_dist_rec.acctd_amount_cr := NULL;
           l_dist_rec.acctd_amount_dr := -l_crh_rec_old.acctd_factor_discount_amount;
        ELSE
           l_dist_rec.acctd_amount_cr := l_crh_rec_old.acctd_factor_discount_amount;
           l_dist_rec.acctd_amount_dr := NULL;
        END IF;
*/
        arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );


     END IF;

     -- Insert value date into CR record

     UPDATE AR_CASH_RECEIPTS
     SET actual_value_date = p_actual_value_date,
         rec_version_number =  nvl(rec_version_number,1)+1 /* bug 3372585 */
     WHERE cash_receipt_id = p_cr_id;

     -- Populate OUT NOCOPY parameters
     p_crh_id := nvl(l_new_crh_id_fr_radj,l_crh_rec_new.cash_receipt_history_id);
   ELSE
     -- if unclear() cannot be performed because of the receipt being
     -- created as CLEARED, we return NULL as crh_id.
     p_crh_id := NULL;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '<<<<<<<< arp_cashbook.unclear' );
   END IF;

EXCEPTION
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_util.debug( 'EXCEPTION: ARP_CASHBOOK.unclear' );
	  END IF;
          RAISE;

END unclear;

PROCEDURE risk_eliminate(
		p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
--
l_crh_rec_old	ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new	ar_cash_receipt_history%ROWTYPE;
l_dist_rec ar_distributions%ROWTYPE;
l_receipt_amt ar_cash_receipt_history.amount%TYPE;
l_acctd_receipt_amt ar_cash_receipt_history.acctd_amount%TYPE;
NULL_VAR   ar_receipt_method_accounts%ROWTYPE;
l_cr_rec        ar_cash_receipts%ROWTYPE;
l_risk_event_rec             arp_xla_events.xla_events_type;

  /* 9363502 - define tables used by refresh_at_risk_value */
  l_customer_id_tab ar_bus_event_sub_pvt.generic_id_type;
  l_site_use_id_tab ar_bus_event_sub_pvt.generic_id_type;
  l_org_id_tab      ar_bus_event_sub_pvt.generic_id_type;
  l_currency_tab    ar_bus_event_sub_pvt.currency_type;
  /* end 9363502 */

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '>>>>>>> arp_cashbook.risk_eliminate' );
   END IF;

   -- Assume this receipt has already been locked

   -- Validate the GL Date is in open or future period

   -- Fetch cash receipt record for 11.5 VAT changes:
   l_cr_rec.cash_receipt_id := p_cr_id;
   arp_cash_receipts_pkg.fetch_p(l_cr_rec);

   -- Fetch the history record
   arp_cr_history_pkg.fetch_f_crid( p_cr_id, l_crh_rec_old );

   --  11.5 VAT changes:
   l_dist_rec.currency_code            := l_cr_rec.currency_code;
   l_dist_rec.currency_conversion_rate := l_crh_rec_old.exchange_rate;
   l_dist_rec.currency_conversion_type := l_crh_rec_old.exchange_rate_type;
   l_dist_rec.currency_conversion_date := l_crh_rec_old.exchange_date;
   l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
   l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;

   -- Check if this receipt has already been risk eliminated,
   -- Also, if it's not factoring, cannot risk eliminate either.
   -- then fail and give an error message.
   IF ( l_crh_rec_old.status = 'RISK_ELIMINATED' ) OR
      ( l_crh_rec_old.factor_flag <> 'Y' )
   THEN
         fnd_message.set_name('AR', 'AR_CANNOT_ELIMINATE_RISK' );
         app_exception.raise_exception;
   END IF;

   -- Insert a new history record
   l_receipt_amt := l_crh_rec_old.amount + nvl(L_crh_rec_old.factor_discount_amount,0);
   l_acctd_receipt_amt := l_crh_rec_old.acctd_amount + nvl(L_crh_rec_old.acctd_factor_discount_amount,0);
   l_crh_rec_new.amount := l_crh_rec_old.amount;
   l_crh_rec_new.factor_discount_amount := l_crh_rec_old.factor_discount_amount;
   l_crh_rec_new.acctd_amount := l_crh_rec_old.acctd_amount;
   l_crh_rec_new.acctd_factor_discount_amount := l_crh_rec_old.acctd_factor_discount_amount;

   l_crh_rec_new.exchange_date := l_crh_rec_old.exchange_date;
   l_crh_rec_new.exchange_rate := l_crh_rec_old.exchange_rate;
   l_crh_rec_new.exchange_rate_type := l_crh_rec_old.exchange_rate_type;
   l_crh_rec_new.cash_receipt_id := p_cr_id;
   l_crh_rec_new.status := 'RISK_ELIMINATED';
   l_crh_rec_new.trx_date := p_trx_date;
   l_crh_rec_new.first_posted_record_flag := 'N';
   l_crh_rec_new.postable_flag := 'Y';
   l_crh_rec_new.factor_flag := l_crh_rec_old.factor_flag;
   l_crh_rec_new.gl_date := p_gl_date;
   l_crh_rec_new.current_record_flag := 'Y';
   arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH','SHORT_TERM_DEBT', NULL_VAR,
				l_crh_rec_new.account_code_combination_id);
   l_crh_rec_new.reversal_gl_date := NULL;
   l_crh_rec_new.reversal_cash_receipt_hist_id := NULL;
   arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'BANK_CHARGES', NULL_VAR,
				l_crh_rec_new.bank_charge_account_ccid);
   l_crh_rec_new.posting_control_id := -3;
   l_crh_rec_new.reversal_posting_control_id := NULL;
   l_crh_rec_new.gl_posted_date := NULL;
   l_crh_rec_new.reversal_gl_posted_date := NULL;
   l_crh_rec_new.prv_stat_cash_receipt_hist_id := l_crh_rec_old.cash_receipt_history_id;
   l_crh_rec_new.created_from := substrb(p_module_name||'ARP_CASHBOOK.RISK_ELIMINATE',1,30);
   l_crh_rec_new.reversal_created_from := NULL;
   arp_cr_history_pkg.insert_p( l_crh_rec_new, l_crh_rec_new.cash_receipt_history_id );

   -- Update the old history record
   l_crh_rec_old.current_record_flag := NULL;
   l_crh_rec_old.reversal_gl_date := p_gl_date;
   l_crh_rec_old.reversal_cash_receipt_hist_id := l_crh_rec_new.cash_receipt_history_id;
   l_crh_rec_old.reversal_posting_control_id := -3;
   l_crh_rec_old.reversal_created_from := substrb(p_module_name||'ARP_CASHBOOK.RISK_ELIMINATE',1,30);
   arp_cr_history_pkg.update_p( l_crh_rec_old );

   /* Bug 6494186 */
    l_risk_event_rec.xla_from_doc_id := p_cr_id;
    l_risk_event_rec.xla_to_doc_id   := p_cr_id;
    l_risk_event_rec.xla_doc_table   := 'CRH';
    l_risk_event_rec.xla_mode        := 'O';
    l_risk_event_rec.xla_call        := 'B';
    arp_xla_events.Create_Events(p_xla_ev_rec => l_risk_event_rec );

   -- Insert the short_term_debt account ar_distributions record
/* skoukunt: comment to Fix bug 1198295
   IF ( l_receipt_amt <>0 ) OR
      ( l_acctd_receipt_amt <> 0 )
   THEN
*/
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'SHORT_TERM_DEBT';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'SHORT_TERM_DEBT', NULL_VAR,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_receipt_amt < 0 )
      THEN
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.amount_cr := -l_receipt_amt;
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.amount_dr := l_receipt_amt;
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
/*
      IF ( l_acctd_receipt_amt < 0 )
      THEN
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.acctd_amount_dr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

--   END IF;

   -- Insert the factor account ar_distributions record
/* skoukunt: comment to Fix bug 1198295
   IF ( l_crh_rec_old.amount <>0 ) OR
      ( l_crh_rec_old.acctd_amount <> 0 )
   THEN
*/
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'FACTOR';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'FACTOR', NULL_VAR,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_receipt_amt < 0 )
      THEN
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.amount_dr := -l_receipt_amt;
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.amount_cr := l_receipt_amt;
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
/*
      IF ( l_acctd_receipt_amt < 0 )
      THEN
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

--   END IF;

   /* 9363502 - set receipt_at_risk_value in ar_trx_val_summary
      for regular and misc receipts */
   IF l_cr_rec.pay_from_customer IS NOT NULL
   THEN

      /* Check for REFRESH running first */
      IF g_refresh_running IS NULL
      THEN
         BEGIN
            select 'Y'
            into   g_refresh_running
            from   ar_conc_process_requests
            where  concurrent_program_name = 'ARSUMREF';
         EXCEPTION
           WHEN OTHERS THEN
              g_refresh_running := 'N';
         END;
      END IF;

      IF g_refresh_running = 'N'
      THEN

         /* 9363502 - Set receipt_at_risk_value in ar_trx_bal_summary */
         l_customer_id_tab(0) := l_cr_rec.pay_from_customer;
         l_site_use_id_tab(0) := NVL(l_cr_rec.customer_site_use_id,-99);
         l_currency_tab(0) :=    l_cr_rec.currency_code;
         l_org_id_tab(0) :=      l_cr_rec.org_id;

         ar_bus_event_sub_pvt.refresh_at_risk_value(l_customer_id_tab,
                                                    l_site_use_id_tab,
                                                    l_currency_tab,
                                                    l_org_id_tab);
      END IF;
   END IF;

   -- Populate OUT NOCOPY parameters
   p_crh_id := l_crh_rec_new.cash_receipt_history_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '<<<<<<<< arp_cashbook.risk_eliminate' );
   END IF;

EXCEPTION
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_util.debug( 'EXCEPTION: ARP_CASHBOOK.risk_eliminate' );
	  END IF;
          RAISE;

END risk_eliminate;

PROCEDURE undo_risk_eliminate(
		p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE ) IS
--
l_crh_rec_old	ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new	ar_cash_receipt_history%ROWTYPE;
l_dist_rec ar_distributions%ROWTYPE;
l_receipt_amt ar_cash_receipt_history.amount%TYPE;
l_acctd_receipt_amt ar_cash_receipt_history.acctd_amount%TYPE;
NULL_VAR   ar_receipt_method_accounts%ROWTYPE;
l_cr_rec   ar_cash_receipts%ROWTYPE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '>>>>>>> arp_cashbook.undo_risk_eliminate' );
   END IF;

   -- Assume this receipt has already been locked

   -- Validate the GL Date is in open or future period

   -- Fetch cash receipt record for 11.5 VAT changes:
   l_cr_rec.cash_receipt_id := p_cr_id;
   arp_cash_receipts_pkg.fetch_p(l_cr_rec);

   -- Fetch the history record
   arp_cr_history_pkg.fetch_f_crid( p_cr_id, l_crh_rec_old );

   --  11.5 VAT changes:
   l_dist_rec.currency_code            := l_cr_rec.currency_code;
   l_dist_rec.currency_conversion_rate := l_crh_rec_old.exchange_rate;
   l_dist_rec.currency_conversion_type := l_crh_rec_old.exchange_rate_type;
   l_dist_rec.currency_conversion_date := l_crh_rec_old.exchange_date;
   l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
   l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;


   -- Check if this receipt has already been risk eliminated,
   -- Also, if it's not factoring, cannot risk eliminate either.
   -- then fail and give an error message.
   IF ( l_crh_rec_old.status <> 'RISK_ELIMINATED' ) OR
      ( l_crh_rec_old.factor_flag <> 'Y' )
   THEN
         fnd_message.set_name('AR', 'AR_CANNOT_UNDO_RISK_ELIMINATE' );
         app_exception.raise_exception;
   END IF;

   -- Insert a new history record
   l_receipt_amt := l_crh_rec_old.amount + nvl(L_crh_rec_old.factor_discount_amount,0);
   l_acctd_receipt_amt := l_crh_rec_old.acctd_amount + nvl(L_crh_rec_old.acctd_factor_discount_amount,0);
   l_crh_rec_new.amount := l_crh_rec_old.amount;
   l_crh_rec_new.factor_discount_amount := l_crh_rec_old.factor_discount_amount;
   l_crh_rec_new.acctd_amount := l_crh_rec_old.acctd_amount;
   l_crh_rec_new.acctd_factor_discount_amount := l_crh_rec_old.acctd_factor_discount_amount;

   l_crh_rec_new.exchange_date := l_crh_rec_old.exchange_date;
   l_crh_rec_new.exchange_rate := l_crh_rec_old.exchange_rate;
   l_crh_rec_new.exchange_rate_type := l_crh_rec_old.exchange_rate_type;
   l_crh_rec_new.cash_receipt_id := p_cr_id;
   l_crh_rec_new.status := 'CLEARED';
   l_crh_rec_new.trx_date := p_trx_date;
   l_crh_rec_new.first_posted_record_flag := 'N';
   l_crh_rec_new.postable_flag := 'Y';
   l_crh_rec_new.factor_flag := l_crh_rec_old.factor_flag;
   l_crh_rec_new.gl_date := p_gl_date;
   l_crh_rec_new.current_record_flag := 'Y';
   arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH','FACTOR', NULL_VAR,
				l_crh_rec_new.account_code_combination_id);
   l_crh_rec_new.reversal_gl_date := NULL;
   l_crh_rec_new.reversal_cash_receipt_hist_id := NULL;
   arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'BANK_CHARGES', NULL_VAR,
				l_crh_rec_new.bank_charge_account_ccid);
   l_crh_rec_new.posting_control_id := -3;
   l_crh_rec_new.reversal_posting_control_id := NULL;
   l_crh_rec_new.gl_posted_date := NULL;
   l_crh_rec_new.reversal_gl_posted_date := NULL;
   l_crh_rec_new.prv_stat_cash_receipt_hist_id := l_crh_rec_old.cash_receipt_history_id;
   l_crh_rec_new.created_from := substrb(p_module_name||'ARP_CASHBOOK.UNDO_RISK_ELIMINATE',1,30);
   l_crh_rec_new.reversal_created_from := NULL;
   arp_cr_history_pkg.insert_p( l_crh_rec_new, l_crh_rec_new.cash_receipt_history_id );

   -- Update the old history record
   l_crh_rec_old.current_record_flag := NULL;
   l_crh_rec_old.reversal_gl_date := p_gl_date;
   l_crh_rec_old.reversal_cash_receipt_hist_id := l_crh_rec_new.cash_receipt_history_id;
   l_crh_rec_old.reversal_posting_control_id := -3;
   l_crh_rec_old.reversal_created_from := substrb(p_module_name||'ARP_CASHBOOK.UNDO_RISK_ELIMINATE',1,30);
   arp_cr_history_pkg.update_p( l_crh_rec_old );

   -- Insert the short_term_debt account ar_distributions record
/* skoukunt: comment to Fix bug 1198295
   IF ( l_receipt_amt <>0 ) OR
      ( l_acctd_receipt_amt <> 0 )
   THEN
*/
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'SHORT_TERM_DEBT';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'SHORT_TERM_DEBT', NULL_VAR,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_receipt_amt < 0 )
      THEN
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.amount_dr := -l_receipt_amt;
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.amount_cr := l_receipt_amt;
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
/*
      IF ( l_acctd_receipt_amt < 0 )
      THEN
         l_dist_rec.acctd_amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.acctd_amount_cr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_dr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);


--   END IF;

   -- Insert the factor account ar_distributions record
/* skoukunt: comment to Fix bug 1198295
   IF ( l_crh_rec_old.amount <>0 ) OR
      ( l_crh_rec_old.acctd_amount <> 0 )
   THEN
*/
      l_dist_rec.source_id := l_crh_rec_new.cash_receipt_history_id;
      l_dist_rec.source_table := 'CRH';
      l_dist_rec.source_type := 'FACTOR';
      arp_cr_util.get_dist_ccid( l_crh_rec_old.cash_receipt_id,
				'CRH', 'FACTOR', NULL_VAR,
				l_dist_rec.code_combination_id);
      -- Fix 1119979, assign acctd_amount_dr and acctd_amount_cr in above condn
      IF ( l_receipt_amt < 0 )
      THEN
         l_dist_rec.amount_dr := NULL;
         l_dist_rec.amount_cr := -l_receipt_amt;
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.amount_dr := l_receipt_amt;
         l_dist_rec.amount_cr := NULL;
         l_dist_rec.acctd_amount_dr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
/*
      IF ( l_acctd_receipt_amt < 0 )
      THEN
         l_dist_rec.acctd_amount_dr := NULL;
         l_dist_rec.acctd_amount_cr := -l_acctd_receipt_amt;
      ELSE
         l_dist_rec.acctd_amount_dr := l_acctd_receipt_amt;
         l_dist_rec.acctd_amount_cr := NULL;
      END IF;
*/
      arp_distributions_pkg.insert_p( l_dist_rec,l_dist_rec.line_id );

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

--   END IF;

   -- Populate OUT NOCOPY parameters
   p_crh_id := l_crh_rec_new.cash_receipt_history_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '<<<<<<<< arp_cashbook.undo_risk_eliminate' );
   END IF;

EXCEPTION
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_util.debug( 'EXCEPTION: ARP_CASHBOOK.undo_risk_eliminate' );
	  END IF;
          RAISE;

END undo_risk_eliminate;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    ins_misc_txn                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates a miscellaneous receipt.                                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   30-SEP-98  K.Murphy        Cash Management Enhancement: Allow creation  |
 |                              of Misc Receipts with distribution set.      |
 |                              Removed code that sets up the misc receipt   |
 |                              distribution record and calls the entity     |
 |                              handler.  Now calls the distribution         |
 |                              procedure passing the activity id.  This     |
 |                              procedure creates the required distribution  |
 |                              rows based on the activity.                  |
 |  04-JAN-99   D. Jancis       Modified for 11.5 VAT project.  Added calls  |
 |                              to get currency_code,                        |
 |                              currency_conversion_rate,                    |
 |                              currency_conversion_type, and                |
 |                              currency_conversion_date                     |
 |  01-MAR-99   D. Jancis       Modified routine to call GUI handler to do   |
 |                              all inserts.  Also added parameter tax_rate  |
 |                              required for VAT                             |
 |  04-JUN-99   GJWANG 		Derive distribution_set_id from in parameter |
 |                              receivables_trx_id when create misc receipt  |
 |  30-SEP-02   R Kader         Bug fix 2300268 : Added a new variable and   |
 |                              used this variable while calling the proc    |
 |                              insert_misc_receipt()
 |  21-FEB-03   R Kader         Bug fix 2742388 : Added a new variable and   |
 |                              used this variable while calling the proc    |
 |                              insert_misc_receipt()
 +===========================================================================*/

PROCEDURE ins_misc_txn(
  p_receipt_number	    IN ar_cash_receipts.receipt_number%TYPE,
  p_document_number	    IN ar_cash_receipts.doc_sequence_value%TYPE,
  p_doc_sequence_id	    IN ar_cash_receipts.doc_sequence_id%TYPE,
  p_gl_date		    IN ar_cash_receipt_history.gl_date%TYPE,
  p_receipt_date	    IN ar_cash_receipts.receipt_date%TYPE,
  p_deposit_date	    IN ar_cash_receipts.deposit_date%TYPE,
  p_receipt_amount	    IN ar_cash_receipts.amount%TYPE,
  p_currency_code	    IN ar_cash_receipts.currency_code%TYPE,
  p_exchange_date           IN ar_cash_receipt_history.exchange_date%TYPE,
  p_exchange_rate_type      IN ar_cash_receipt_history.exchange_rate_type%TYPE,
  p_exchange_rate	    IN ar_cash_receipt_history.exchange_rate%TYPE,
  p_receipt_method_id	    IN ar_cash_receipts.receipt_method_id%TYPE,
  p_remit_bank_account_id   IN ar_cash_receipts.remit_bank_acct_use_id%TYPE,
  p_receivables_trx_id	    IN ar_cash_receipts.receivables_trx_id%TYPE,
  p_comments		    IN ar_cash_receipts.comments%TYPE,
  p_vat_tax_id		    IN ar_cash_receipts.vat_tax_id%TYPE,
  p_reference_type	    IN ar_cash_receipts.reference_type%TYPE,
  p_reference_id	    IN ar_cash_receipts.reference_id%TYPE,
  p_misc_payment_source     IN ar_cash_receipts.misc_payment_source%TYPE,
  p_anticipated_clearing_date IN ar_cash_receipts.anticipated_clearing_date%TYPE,
  p_module_name   	    IN VARCHAR2,
  p_module_version   	    IN VARCHAR2,
  p_cr_id		    OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
  p_tax_rate                IN NUMBER ) IS
--
p_row_id       VARCHAR2(30);
l_cr_id        ar_cash_Receipts.cash_receipt_id%TYPE;
l_dis_set_id   ar_cash_receipts.distribution_set_id%TYPE;
/* Bug fix 2300268 */
l_tax_account_id               ar_distributions.code_combination_id%TYPE;
/* Bug fix 2742388 */
l_crh_id                       ar_cash_receipt_history.cash_receipt_history_id%TYPE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '>>>>>>> arp_cashbook.ins_misc_txn' );
   END IF;

   SELECT default_acctg_distribution_set
   INTO   l_dis_set_id
   FROM   ar_receivables_trx
   WHERE  receivables_trx_id = p_receivables_trx_id;

   /* Bug fix 2300268
      Get the tax account id corresponding to the vat_tax_id */
      IF p_vat_tax_id IS NOT NULL THEN
        /* bug 6034914  , commented out the select and added next 6 lines.
        SELECT tax_account_id
        INTO   l_tax_account_id
        FROM   ar_vat_tax
        WHERE  vat_tax_id = p_vat_tax_id;
        */
        l_tax_account_id := arp_etax_util.get_tax_account(p_vat_tax_id,
			       trunc(p_receipt_date),'TAX','TAX_RATE');
	if l_tax_account_id = -1
	then
	 l_tax_account_id := NULL;
	end if;
     ELSE
        l_tax_account_id := NULL;
     END IF;
  /* End Bug fix 2300268 */

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ins_misc_txn: ' || ' ====> Receipt_number ' || p_receipt_number);
      arp_util.debug('ins_misc_txn: ' || ' ====> distribution_set_id ' || l_dis_set_id);
   END IF;

   -- Bugs 975560/962254: Added NULL for P_USSGL_TRANSACTION_CODE
   -- parameter.

   ARP_PROCESS_MISC_RECEIPTS.insert_misc_receipt (
                            p_currency_code,
                            p_receipt_amount,
                            p_receivables_trx_id,
                            p_misc_payment_source,
                            p_receipt_number,
                            p_receipt_date,
                            p_gl_date,
                            p_comments,
                            p_exchange_rate_type,
                            p_exchange_rate,
                            p_exchange_date,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            p_remit_bank_account_id,
                            p_deposit_date,
                            p_receipt_method_id,
                            p_document_number,
                            p_doc_sequence_id,
                            l_dis_set_id,
                            p_reference_type,
                            p_reference_id,
                            p_vat_tax_id,
			    NULL,              -- Bug 975560/962254
                            p_anticipated_clearing_date,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            l_cr_id,
                            p_row_id,
                            p_module_name,
                            p_module_version,
                            p_tax_rate,
                            l_tax_account_id, /* Bug fix 2300268 */
                            l_crh_id); /* Bug fix 2742388 */

   -- Populate OUT NOCOPY parameters
   p_cr_id := l_cr_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '<<<<<<<< arp_cashbook.ins_misc_txn' );
   END IF;

EXCEPTION
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_util.debug( 'EXCEPTION: arp_cashbook.ins_misc_txn' );
	  END IF;
          RAISE;

END ins_misc_txn;

PROCEDURE reverse(
	p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
	p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
	p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
	p_reversal_reason_code	IN ar_cash_receipts.reversal_reason_code%TYPE,
	p_reversal_category	IN ar_cash_receipts.reversal_category%TYPE,
	p_module_name   	IN VARCHAR2,
	p_module_version   	IN VARCHAR2,
	p_crh_id  OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE) IS

  CURSOR current_crh_cur IS
    SELECT crh.cash_receipt_history_id
    FROM ar_cash_receipt_history crh
    WHERE crh.cash_receipt_id     = p_cr_id
    AND   crh.current_record_flag = 'Y'
    AND   crh.status              = 'REVERSED';

  l_reversal_category	     AR_CASH_RECEIPTS.REVERSAL_CATEGORY%TYPE;
  l_reversal_reason_code     AR_CASH_RECEIPTS.REVERSAL_REASON_CODE%TYPE;
  l_attribute_rec            AR_RECEIPT_API_PUB.ATTRIBUTE_REC_TYPE; /* Added for bug 2688370 */
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_cr_id                    NUMBER;
  current_crh_rec            current_crh_cur%ROWTYPE;
  API_exception              EXCEPTION;
  l_msg_index                number;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '>>>>>>> arp_cashbook.reverse' );
   END IF;

   -- if reversal category and reversal reason code are not
   -- passed in by CE, use 'NSF' as a default.

   IF (p_reversal_category IS NULL) THEN
     l_reversal_category := 'NSF';
   ELSE
     l_reversal_category := p_reversal_category;
   END IF;

   IF (p_reversal_reason_code IS NULL) THEN
     l_reversal_reason_code := 'NSF';
   ELSE
     l_reversal_reason_code := p_reversal_reason_code;
   END IF;

   /* Bugfix 2688370. Code modified so that the DFF values are passed
      to the call of  AR_RECEIPT_API_PUB.Reverse */
   SELECT attribute_category,
          attribute1, attribute2,
	  attribute3, attribute4,
	  attribute5, attribute6,
          attribute7, attribute8,
	  attribute9, attribute10,
	  attribute11, attribute12,
          attribute13, attribute14,
	  attribute15
   INTO   l_attribute_rec.attribute_category,
          l_attribute_rec.attribute1, l_attribute_rec.attribute2,
	  l_attribute_rec.attribute3, l_attribute_rec.attribute4,
	  l_attribute_rec.attribute5, l_attribute_rec.attribute6,
          l_attribute_rec.attribute7, l_attribute_rec.attribute8,
	  l_attribute_rec.attribute9, l_attribute_rec.attribute10,
	  l_attribute_rec.attribute11, l_attribute_rec.attribute12,
          l_attribute_rec.attribute13, l_attribute_rec.attribute14,
	  l_attribute_rec.attribute15
   FROM   ar_cash_receipts
   WHERE  cash_receipt_id = p_cr_id;

   BEGIN

     AR_RECEIPT_API_PUB.Reverse(p_api_version                  => 1.0,
                                p_init_msg_list                => FND_API.G_TRUE,
                                x_return_status                => l_return_status,
                                x_msg_count                    => l_msg_count,
                                x_msg_data                     => l_msg_data,
                                p_cash_receipt_id              => p_cr_id,
                                p_reversal_category_code       => l_reversal_category,
                                p_reversal_gl_date             => p_reversal_gl_date,
                                p_reversal_date                => p_reversal_date,
                                p_reversal_reason_code         => l_reversal_reason_code,
                                p_reversal_comments            => p_reversal_comments,
				p_attribute_rec		       => l_attribute_rec,
                                p_called_from                  => 'ARRECBKB');

   /*------------------------------------------------+
    | Write API output to the concurrent program log |
    +------------------------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('reverse: ' || 'API error count '||to_char(NVL(l_msg_count,0)));
    END IF;

    IF NVL(l_msg_count,0)  > 0 Then

      IF l_msg_count  = 1 Then
       /*------------------------------------------------+
        | There is one message returned by the API, so it|
        | has been sent out NOCOPY in the parameter x_msg_data  |
        +------------------------------------------------*/
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('reverse: ' || l_msg_data);
        END IF;

      ELSIF l_msg_count > 1 Then

       /*-------------------------------------------------------+
        | There are more than one messages returned by the API, |
        | so call them in a loop and print the messages         |
        +-------------------------------------------------------*/

        FOR l_count IN 1..l_msg_count LOOP

             l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('reverse: ' || to_char(l_count)||' : '||l_msg_data);
             END IF;

        END LOOP;

      END IF;

    END IF;

   /*-----------------------------------------------------+
    | If API return status is not SUCCESS raise exception |
    +-----------------------------------------------------*/
    IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

     /*-----------------------------------------------------+
      | Success do nothing, else branch introduced to make  |
      | sure that NULL case will also raise exception       |
      +-----------------------------------------------------*/
      NULL;

    ELSE
     /*---------------------------+
      | Error, raise an exception |
      +---------------------------*/
      RAISE API_exception;

    END IF;

   /*----------------------------------+
    | APIs propagate exception upwards |
    +----------------------------------*/
    EXCEPTION
      WHEN API_exception THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('API Exception: arp_cashbook.reverse '||SQLERRM);
        END IF;
        FND_MSG_PUB.Get (FND_MSG_PUB.G_FIRST, FND_API.G_TRUE, l_msg_data, l_msg_index);
        FND_MESSAGE.Set_Encoded (l_msg_data);
        app_exception.raise_exception;

      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Exception: arp_cashbook.reverse '||SQLERRM);
        END IF;
        fnd_message.set_name('AR', 'AR_BR_CANNOT_REVERSE_REC');
        app_exception.raise_exception;

    END;

   -- Populate OUT NOCOPY parameters
   OPEN current_crh_cur;
   FETCH current_crh_cur INTO current_crh_rec;

   IF current_crh_cur%NOTFOUND THEN
     app_exception.raise_exception;
   END IF;

   CLOSE current_crh_cur;

   p_crh_id := current_crh_rec.cash_receipt_history_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( '<<<<<<<< arp_cashbook.reverse' );
   END IF;

EXCEPTION
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_util.debug( 'EXCEPTION: ARP_CASHBOOK.reverse' );
	  END IF;
          RAISE;

END reverse;

PROCEDURE debit_memo_reversal (
  p_cash_receipt_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
  p_cc_id                 IN ra_cust_trx_line_gl_dist.code_combination_id%TYPE,
  p_dm_cust_trx_type_id   IN ra_cust_trx_types.cust_trx_type_id%TYPE,
  p_dm_cust_trx_type      IN ra_cust_trx_types.name%TYPE,
  p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
  p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
  p_reversal_category     IN ar_cash_receipts.reversal_category%TYPE,
  p_reversal_reason_code  IN ar_cash_receipts.reversal_reason_code%TYPE,
  p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
  p_dm_number             OUT NOCOPY ar_payment_schedules.trx_number%TYPE,
  p_dm_doc_sequence_value IN ra_customer_trx.doc_sequence_value%TYPE,
  p_dm_doc_sequence_id    IN ra_customer_trx.doc_sequence_id%TYPE,
  p_tw_status             IN OUT NOCOPY VARCHAR2,
  p_module_name           IN VARCHAR2,
  p_module_version        IN VARCHAR2
                              ) IS

  CURSOR applied_to_reserved_br_cur IS
    SELECT 'Y'
    FROM   ar_payment_schedules ps,
           ar_receivable_applications ra
    WHERE  ra.cash_receipt_id = p_cash_receipt_id
    AND  ra.applied_payment_schedule_id = ps.payment_schedule_id
    AND  ps.reserved_type  IS NOT NULL
    AND  ps.reserved_value IS NOT NULL
    AND  ra.status         = 'APP'
    AND  ra.display        = 'Y';

  CURSOR applied_to_std_cur IS
    SELECT 'Y'
    FROM   ar_receivable_applications ra
    WHERE  ra.cash_receipt_id = p_cash_receipt_id
    AND  ra.applied_payment_schedule_id = -2
    AND  ra.display                     = 'Y';

  l_cr_rec                    ar_cash_receipts%ROWTYPE;
  l_dm_number                 ar_payment_schedules.trx_number%TYPE;
  applied_to_reserved_br_rec  applied_to_reserved_br_cur%ROWTYPE;
  applied_to_std_rec          applied_to_std_cur%ROWTYPE;


BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('>>>>>>>>>>>>>  arp_cashbook.debit_memo_reversal ');
    END IF;

    OPEN applied_to_std_cur;
    FETCH applied_to_std_cur INTO applied_to_std_rec;

    IF applied_to_std_cur%FOUND THEN
      fnd_message.set_name('AR', 'AR_RW_CANNOT_REVERSE_BR_STD');
      app_exception.raise_exception;
    END IF;

    CLOSE applied_to_std_cur;

    OPEN applied_to_reserved_br_cur;
    FETCH applied_to_reserved_br_cur INTO applied_to_reserved_br_rec;

    IF applied_to_reserved_br_cur%FOUND THEN
      fnd_message.set_name('AR', 'AR_RW_CANNOT_REVERSE_BR_STD');
      app_exception.raise_exception;
    END IF;

    CLOSE applied_to_reserved_br_cur;

    -- get cash receipt record:
    l_cr_rec.cash_receipt_id := p_cash_receipt_id;
    arp_cash_receipts_pkg.nowaitlock_fetch_p(l_cr_rec);


    arp_reverse_receipt.debit_memo_reversal(
                l_cr_rec,
                p_cc_id,
                p_dm_cust_trx_type_id,
                p_dm_cust_trx_type,
                p_reversal_gl_date,
                p_reversal_date,
                p_reversal_category,
                p_reversal_reason_code,
                p_reversal_comments,
                NULL, NULL,
                NULL, NULL, NULL,
                NULL, NULL, NULL,
                NULL, NULL, NULL,
                NULL, NULL, NULL,
                NULL, NULL,
                l_dm_number,
                p_dm_doc_sequence_value,
                p_dm_doc_sequence_id,
                p_tw_status,
                p_module_name,
                p_module_version);

   -- Populate OUT NOCOPY parameters
   p_dm_number := l_dm_number;

EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: ARP_CASHBOOK.debit_memo_reversal');
        END IF;
        RAISE;
END debit_memo_reversal;


PROCEDURE Lock_Row(
        P_BATCH_ID                      IN ar_batches.batch_id%TYPE,
        P_AMOUNT                        IN ar_cash_receipt_history.amount%TYPE,
        P_ACCTD_AMOUNT                  IN ar_cash_receipt_history.acctd_amount%TYPE,
        P_NAME                          IN ar_batches.name%TYPE,
        P_BATCH_DATE                    IN ar_batches.batch_date%TYPE,
        P_GL_DATE                       IN ar_batches.gl_date%TYPE,
        P_STATUS                        IN ar_batches.status%TYPE,
        P_DEPOSIT_DATE                  IN ar_batches.deposit_date%TYPE,
        P_CLOSED_DATE                   IN ar_batches.closed_date%TYPE,
        P_TYPE                          IN ar_batches.type%TYPE,
        P_BATCH_SOURCE_ID               IN ar_batches.batch_source_id%TYPE,
        P_CONTROL_COUNT                 IN ar_batches.control_count%TYPE,
        P_CONTROL_AMOUNT                IN ar_batches.control_amount%TYPE,
        P_BATCH_APPLIED_STATUS          IN ar_batches.batch_applied_status%TYPE,
        P_CURRENCY_CODE                 IN ar_batches.currency_code%TYPE,
        P_EXCHANGE_RATE_TYPE            IN ar_batches.exchange_rate_type%TYPE,
        P_EXCHANGE_DATE                 IN ar_batches.exchange_date%TYPE,
        P_EXCHANGE_RATE                 IN ar_batches.exchange_rate%TYPE,
        P_TRANSMISSION_REQUEST_ID       IN ar_batches.transmission_request_id%TYPE,
        P_LOCKBOX_ID                    IN ar_batches.lockbox_id%TYPE,
        P_LOCKBOX_BATCH_NAME            IN ar_batches.lockbox_batch_name%TYPE,
        P_COMMENTS                      IN ar_batches.comments%TYPE,
        P_ATTRIBUTE_CATEGORY            IN ar_batches.attribute_category%TYPE,
        P_ATTRIBUTE1                    IN ar_batches.attribute1%TYPE,
        P_ATTRIBUTE2                    IN ar_batches.attribute2%TYPE,
        P_ATTRIBUTE3                    IN ar_batches.attribute3%TYPE,
        P_ATTRIBUTE4                    IN ar_batches.attribute4%TYPE,
        P_ATTRIBUTE5                    IN ar_batches.attribute5%TYPE,
        P_ATTRIBUTE6                    IN ar_batches.attribute6%TYPE,
        P_ATTRIBUTE7                    IN ar_batches.attribute7%TYPE,
        P_ATTRIBUTE8                    IN ar_batches.attribute8%TYPE,
        P_ATTRIBUTE9                    IN ar_batches.attribute9%TYPE,
        P_ATTRIBUTE10                   IN ar_batches.attribute10%TYPE,
        P_MEDIA_REFERENCE               IN ar_batches.media_reference%TYPE,
        P_OPERATION_REQUEST_ID          IN ar_batches.operation_request_id%TYPE,
        P_RECEIPT_METHOD_ID             IN ar_batches.receipt_method_id%TYPE,
        P_REMITTANCE_BANK_ACCOUNT_ID    IN ar_batches.remit_bank_acct_use_id%TYPE,
        P_RECEIPT_CLASS_ID              IN ar_batches.receipt_class_id%TYPE,
        P_ATTRIBUTE11                   IN ar_batches.attribute11%TYPE,
        P_ATTRIBUTE12                   IN ar_batches.attribute12%TYPE,
        P_ATTRIBUTE13                   IN ar_batches.attribute13%TYPE,
        P_ATTRIBUTE14                   IN ar_batches.attribute14%TYPE,
        P_ATTRIBUTE15                   IN ar_batches.attribute15%TYPE,
        P_PROGRAM_APPLICATION_ID        IN ar_batches.program_application_id%TYPE,
        P_PROGRAM_ID                    IN ar_batches.program_id%TYPE,
        P_PROGRAM_UPDATE_DATE           IN ar_batches.program_update_date%TYPE,
        P_REMITTANCE_BANK_BRANCH_ID     IN ar_batches.remittance_bank_branch_id%TYPE,
        P_REMIT_METHOD_CODE             IN ar_batches.remit_method_code%TYPE,
        P_REQUEST_ID                    IN ar_batches.request_id%TYPE,
        P_SET_OF_BOOKS_ID               IN ar_batches.set_of_books_id%TYPE,
        P_TRANSMISSION_ID               IN ar_batches.transmission_id%TYPE,
        P_BANK_DEPOSIT_NUMBER           IN ar_batches.bank_deposit_number%TYPE)
IS

 CURSOR C IS
                SELECT crh.cash_receipt_history_id
                FROM   ar_cash_receipt_history crh, ar_cash_receipts acr
                WHERE  crh.batch_id = P_BATCH_ID
                  AND  crh.status not in ('REVERSED')
                  AND  crh.cash_receipt_id = acr.cash_receipt_id
                FOR UPDATE NOWAIT;

        CURSOR BATCH IS
                SELECT *
                FROM ar_batches
                WHERE batch_id = P_BATCH_ID
	        FOR UPDATE NOWAIT;

        Recinfo         C%ROWTYPE;
        Batchinfo       BATCH%ROWTYPE;
        c_batch_id      ar_batches.batch_id%TYPE;
	c_amount	ar_cash_receipt_history.amount%TYPE;
	c_acctd_amount	ar_cash_receipt_history.acctd_amount%TYPE;

  BEGIN

        OPEN C;
	CLOSE C;

        OPEN BATCH;
        FETCH BATCH INTO Batchinfo;
        if (BATCH%NOTFOUND) then
         CLOSE BATCH;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
        end if;
        CLOSE BATCH;

        SELECT sum(amount) , sum(acctd_amount)
	INTO c_amount, c_acctd_amount
        FROM   ar_cash_receipt_history
        WHERE  batch_id = P_BATCH_ID
          AND  status not in ('REVERSED');


	 if (   (c_amount                             = P_AMOUNT          OR
		(c_amount is NULL AND P_AMOUNT is NULL))
            AND (c_acctd_amount                       = P_ACCTD_AMOUNT    OR
		(c_acctd_amount is NULL AND P_ACCTD_AMOUNT is NULL))
            AND (Batchinfo.batch_id                   = P_BATCH_ID        OR
		(Batchinfo.batch_id is NULL AND P_BATCH_ID is NULL))
            AND (Batchinfo.name                       = P_NAME            OR
		(Batchinfo.name is NULL AND P_NAME is NULL))
            AND (Batchinfo.batch_date                 = P_BATCH_DATE      OR
		(Batchinfo.batch_date is NULL AND P_BATCH_DATE is NULL))
            AND (Batchinfo.gl_date                    = P_GL_DATE         OR
		(Batchinfo.gl_date is NULL AND P_GL_DATE is NULL))
            AND (Batchinfo.status                     = P_STATUS          OR
		(Batchinfo.status is NULL AND P_STATUS is NULL))
            AND (Batchinfo.deposit_date               = P_DEPOSIT_DATE    OR
		(Batchinfo.deposit_date is NULL AND P_DEPOSIT_DATE is NULL))
            AND (Batchinfo.closed_date                = P_CLOSED_DATE     OR
		(Batchinfo.closed_date is NULL AND P_CLOSED_DATE is NULL))
            AND (Batchinfo.type                       = P_TYPE            OR
		(Batchinfo.type is NULL AND P_TYPE is NULL))
            AND (Batchinfo.batch_source_id            = P_BATCH_SOURCE_ID OR
		(Batchinfo.batch_source_id is NULL AND P_BATCH_SOURCE_ID is NULL))
            AND (Batchinfo.control_count              = P_CONTROL_COUNT   OR
		(Batchinfo.control_count is NULL AND P_CONTROL_COUNT is NULL))
            AND (Batchinfo.control_amount             = P_CONTROL_AMOUNT  OR
		(Batchinfo.control_amount is NULL AND P_CONTROL_AMOUNT is NULL))
            AND (Batchinfo.batch_applied_status       = P_BATCH_APPLIED_STATUS OR
		(Batchinfo.batch_applied_status is NULL AND P_BATCH_APPLIED_STATUS is NULL))
            AND (Batchinfo.currency_code              = P_CURRENCY_CODE   OR
		(Batchinfo.currency_code is NULL AND P_CURRENCY_CODE is NULL))
            AND (Batchinfo.exchange_rate_type         = P_EXCHANGE_RATE_TYPE  OR
		(Batchinfo.exchange_rate_type is NULL AND P_EXCHANGE_RATE_TYPE is NULL))
            AND (Batchinfo.exchange_date              = P_EXCHANGE_DATE   OR
		(Batchinfo.exchange_date is NULL AND P_EXCHANGE_DATE is NULL))
            AND (Batchinfo.exchange_rate              = P_EXCHANGE_RATE   OR
		(Batchinfo.exchange_rate is NULL AND P_EXCHANGE_RATE is NULL))
            AND (Batchinfo.transmission_request_id    = P_TRANSMISSION_REQUEST_ID OR
		(Batchinfo.transmission_request_id is NULL AND P_TRANSMISSION_REQUEST_ID is NULL))
            AND (Batchinfo.lockbox_id                 = P_LOCKBOX_ID      OR
		(Batchinfo.lockbox_id is NULL AND P_LOCKBOX_ID is NULL))
            AND (Batchinfo.lockbox_batch_name         = P_LOCKBOX_BATCH_NAME  OR
		(Batchinfo.lockbox_batch_name is NULL AND P_LOCKBOX_BATCH_NAME is NULL))
            AND (Batchinfo.comments                   = P_COMMENTS        OR
		(Batchinfo.comments is NULL and P_COMMENTS is NULL))
	    AND (Batchinfo.attribute_category         = P_ATTRIBUTE_CATEGORY OR
		(Batchinfo.attribute_category is NULL AND P_ATTRIBUTE_CATEGORY is NULL))
            AND (Batchinfo.attribute1                 = P_ATTRIBUTE1         OR
		(Batchinfo.attribute1 is NULL AND P_ATTRIBUTE1 is NULL))
	    AND (Batchinfo.attribute2                 = P_ATTRIBUTE2         OR
		(Batchinfo.attribute2 is NULL AND P_ATTRIBUTE2 is NULL))
            AND (Batchinfo.attribute3                 = P_ATTRIBUTE3         OR
		(Batchinfo.attribute3 is NULL AND P_ATTRIBUTE3 is NULL))
            AND (Batchinfo.attribute4                 = P_ATTRIBUTE4         OR
		(Batchinfo.attribute4 is NULL AND P_ATTRIBUTE4 is NULL))
            AND (Batchinfo.attribute5                 = P_ATTRIBUTE5         OR
		(Batchinfo.attribute5 is NULL AND P_ATTRIBUTE5 is NULL))
            AND (Batchinfo.attribute6                 = P_ATTRIBUTE6         OR
		(Batchinfo.attribute6 is NULL AND P_ATTRIBUTE6 is NULL))
            AND (Batchinfo.attribute7                 = P_ATTRIBUTE7         OR
		(Batchinfo.attribute7 is NULL AND P_ATTRIBUTE7 is NULL))
            AND (Batchinfo.attribute8                 = P_ATTRIBUTE8         OR
		(Batchinfo.attribute8 is NULL AND P_ATTRIBUTE8 is NULL))
            AND (Batchinfo.attribute9                 = P_ATTRIBUTE9         OR
		(Batchinfo.attribute9 is NULL AND P_ATTRIBUTE9 is NULL))
            AND (Batchinfo.attribute10                = P_ATTRIBUTE10        OR
		(Batchinfo.attribute10 is NULL AND P_ATTRIBUTE10 is NULL))
            AND (Batchinfo.media_reference            = P_MEDIA_REFERENCE    OR
		(Batchinfo.media_reference is NULL AND P_MEDIA_REFERENCE is NULL))
            AND (Batchinfo.operation_request_id       = P_OPERATION_REQUEST_ID  OR
		(Batchinfo.operation_request_id is NULL AND P_OPERATION_REQUEST_ID is NULL))
            AND (Batchinfo.receipt_method_id          = P_RECEIPT_METHOD_ID  OR
		(Batchinfo.receipt_method_id is NULL AND P_RECEIPT_METHOD_ID is NULL))
            AND (Batchinfo.remit_bank_acct_use_id = P_REMITTANCE_BANK_ACCOUNT_ID  OR
		(Batchinfo.remit_bank_acct_use_id is NULL AND P_REMITTANCE_BANK_ACCOUNT_ID is NULL))
            AND (Batchinfo.receipt_class_id           = P_RECEIPT_CLASS_ID   OR
		(Batchinfo.receipt_class_id is NULL AND P_RECEIPT_CLASS_ID is NULL))
            AND (Batchinfo.attribute11                = P_ATTRIBUTE11        OR
		(Batchinfo.attribute11 is NULL AND P_ATTRIBUTE11 is NULL))
            AND (Batchinfo.attribute12                = P_ATTRIBUTE12        OR
		(Batchinfo.attribute12 is NULL AND P_ATTRIBUTE12 is NULL))
            AND (Batchinfo.attribute13                = P_ATTRIBUTE13        OR
		(Batchinfo.attribute13 is NULL AND P_ATTRIBUTE13 is NULL))
            AND (Batchinfo.attribute14                = P_ATTRIBUTE14        OR
		(Batchinfo.attribute14 is NULL AND P_ATTRIBUTE14 is NULL))
            AND (Batchinfo.attribute15                = P_ATTRIBUTE15        OR
		(Batchinfo.attribute15 is NULL AND P_ATTRIBUTE15 is NULL))
            AND (Batchinfo.program_application_id     = P_PROGRAM_APPLICATION_ID OR
		(Batchinfo.program_application_id is NULL AND P_PROGRAM_APPLICATION_ID is NULL))
            AND (Batchinfo.program_id                 = P_PROGRAM_ID         OR
		(Batchinfo.program_id is NULL AND P_PROGRAM_ID is NULL))
            AND (Batchinfo.program_update_date        = P_PROGRAM_UPDATE_DATE OR
		(Batchinfo.program_update_date is NULL AND P_PROGRAM_UPDATE_DATE is NULL))
            AND (Batchinfo.remittance_bank_branch_id  = P_REMITTANCE_BANK_BRANCH_ID OR
		(Batchinfo.remittance_bank_branch_id is NULL AND P_REMITTANCE_BANK_BRANCH_ID is NULL))
            AND (Batchinfo.remit_method_code          = P_REMIT_METHOD_CODE   OR
		(Batchinfo.remit_method_code is NULL AND P_REMIT_METHOD_CODE is NULL))
            AND (Batchinfo.request_id                 = P_REQUEST_ID          OR
		(Batchinfo.request_id is NULL AND P_REQUEST_ID is NULL))
            AND (Batchinfo.set_of_books_id            = P_SET_OF_BOOKS_ID     OR
		(Batchinfo.set_of_books_id is NULL AND P_SET_OF_BOOKS_ID is NULL))
            AND (Batchinfo.transmission_id            = P_TRANSMISSION_ID     OR
		(Batchinfo.transmission_id is NULL AND P_TRANSMISSION_ID is NULL))
            AND (Batchinfo.bank_deposit_number        = P_BANK_DEPOSIT_NUMBER OR
		(Batchinfo.bank_deposit_number is NULL AND P_BANK_DEPOSIT_NUMBER is NULL))
           )
        then
          return;
        else
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.Raise_Exception;
        end if;
  END Lock_Row;

/* ----------------------------------------------------------------------
   Function receipt_debit_memo_reversed

   Parameters:  p_cash_receipt_id

   Return Value:  VARCHAR2(1)    'Y' if receipt was debit-memo-reversed
                                 'N' if receipt was not debit-memo-reversed

   This function was added for CE enhancement request 681187.  The function
   can be used in a view to determine if a given receipt was debit-memo-
   reversed.
   Note that the function will return 'N' if the receipt was reversed
   with normal (non-debit-memo) reversal.  It will also return 'N'
   if the passed in parameter is not a valid cash_receipt_id, i.e.,
   there is no error handling for this case.

   Modification History:

   08-JUL-98    Guat Eng Tan   created
   ---------------------------------------------------------------------- */


FUNCTION receipt_debit_memo_reversed( p_cash_receipt_id IN NUMBER)
                           RETURN VARCHAR2 IS
  l_result  VARCHAR2(1);
BEGIN

  BEGIN
    SELECT 'Y'
    INTO   l_result
    FROM   ar_payment_schedules ps_dm
    WHERE  ps_dm.reversed_cash_receipt_id = p_cash_receipt_id
      AND  ps_dm.class = 'DM';

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_result := 'N';
    WHEN OTHERS THEN
       RAISE;
  END;

  RETURN l_result;

END;


PROCEDURE update_actual_value_date(p_cash_receipt_id IN NUMBER,
		p_actual_value_date IN DATE) IS
BEGIN

  UPDATE AR_CASH_RECEIPTS
  SET actual_value_date = p_actual_value_date,
      rec_version_number =  nvl(rec_version_number,1)+1 /* bug 3372585 */
  WHERE cash_receipt_id = p_cash_receipt_id;

END;

FUNCTION revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.19.12010000.9 $';

END revision;

END ARP_CASHBOOK;

/
