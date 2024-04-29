--------------------------------------------------------
--  DDL for Package Body AR_IREC_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_IREC_PAYMENTS" AS
/* $Header: ARIRPMTB.pls 120.55.12010000.33 2010/06/09 13:09:13 nkanchan ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'AR_IREC_PAYMENTS';


TYPE INVOICE_REC_TYPE IS RECORD
     (PAYMENT_SCHEDULE_ID     NUMBER(15),
      PAYMENT_AMOUNT		  NUMBER,
      CUSTOMER_ID             NUMBER(15),
      ACCOUNT_NUMBER          VARCHAR2(30),
      CUSTOMER_TRX_ID         NUMBER(15),
      CURRENCY_CODE           VARCHAR2(15),
      SERVICE_CHARGE          NUMBER
     );

TYPE INVOICE_LIST_TABTYPE IS TABLE OF INVOICE_REC_TYPE;


/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


  FUNCTION get_iby_account_type(p_account_type        IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE write_debug_and_log(p_message IN VARCHAR2);

  PROCEDURE write_API_output(p_msg_count        IN NUMBER,
                             p_msg_data         IN VARCHAR2);

  PROCEDURE apply_service_charge ( p_customer_id		  IN NUMBER,
                                   p_site_use_id          IN NUMBER DEFAULT NULL,
                                   x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE apply_cash ( p_customer_id		    IN NUMBER,
                         p_site_use_id          IN NUMBER DEFAULT NULL,
                         p_cash_receipt_id      IN NUMBER,
                         p_return_status         OUT NOCOPY VARCHAR2,
                         p_apply_err_count       OUT NOCOPY NUMBER,
                         x_msg_count           OUT NOCOPY NUMBER,
                         x_msg_data            OUT NOCOPY VARCHAR2
                       );

  PROCEDURE create_receipt (p_payment_amount        IN NUMBER,
                            p_customer_id           IN NUMBER,
                            p_site_use_id           IN NUMBER,
                            p_bank_account_id       IN NUMBER,
                            p_receipt_date          IN DATE DEFAULT trunc(SYSDATE),
                            p_receipt_method_id     IN NUMBER,
                            p_receipt_currency_code IN VARCHAR2,
                            p_receipt_exchange_rate IN NUMBER,
                            p_receipt_exchange_rate_type IN VARCHAR2,
                            p_receipt_exchange_rate_date IN DATE,
                            p_trxn_extn_id	    IN NUMBER,
                            p_cash_receipt_id       OUT NOCOPY NUMBER,
                            p_status                OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE process_payment(
		p_cash_receipt_id     IN  NUMBER,
	        p_payer_rec           IN  IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
	        P_payee_rec           IN  IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type,
                p_called_from         IN  VARCHAR2,
                p_response_error_code OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
	        x_return_status       OUT NOCOPY VARCHAR2
                           );

 PROCEDURE update_cc_bill_to_site(
		p_cc_location_rec	IN   HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
		x_cc_bill_to_site_id	IN  NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_count		OUT NOCOPY NUMBER,
		x_msg_data		OUT NOCOPY VARCHAR2);

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/
/*========================================================================
 | PUBLIC function get_credit_card_type
 |
 | DESCRIPTION
 |      Determines if a credit card number is valid
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 |
 |
 |
 | PARAMETERS
 |      credit_card_number   IN      Credit card number --
 |                                   without white spaces
 |
 | RETURNS
 |      TRUE  if credit card number is valid
 |      FALSE if credit card number is invalid
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 23-JAN-2001           O Steinmeier      Created
 |
 *=======================================================================*/
FUNCTION is_credit_card_number_valid(  p_credit_card_number IN  VARCHAR2 )
         RETURN NUMBER IS


  TYPE numeric_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;
  TYPE character_tab_typ IS TABLE of char(1) INDEX BY BINARY_INTEGER;

  l_stripped_num_table		numeric_tab_typ;   /* Holds credit card number stripped of white spaces */
  l_product_table		numeric_tab_typ;   /* Table of cc digits multiplied by 2 or 1,for validity check */
  l_len_credit_card_num   	number := 0;  	   /* Length of credit card number stripped of white spaces */
  l_product_tab_sum   		number := 0;  	   /* Sum of digits in product table */
  l_actual_cc_check_digit       number := 0;  	   /* First digit of credit card, numbered from right to left */
  l_mod10_check_digit        	number := 0;  	   /* Check digit after mod10 algorithm is applied */
  j 				number := 0;  	   /* Product table index */
  BEGIN
	arp_util.debug('ar_irec_payments_pkg.is_credit_card_number_valid()+0');

	SELECT lengthb(p_credit_card_number)
	INTO   l_len_credit_card_num
	FROM   dual;

	FOR i in 1..l_len_credit_card_num LOOP
		SELECT to_number(substrb(p_credit_card_number,i,1))
		INTO   l_stripped_num_table(i)
		FROM   dual;
	END LOOP;
	l_actual_cc_check_digit := l_stripped_num_table(l_len_credit_card_num);

	FOR i in 1..l_len_credit_card_num-1 LOOP
		IF ( mod(l_len_credit_card_num+1-i,2) > 0 )
		THEN
		    -- Odd numbered digit.  Store as is, in the product table.
		    j := j+1;
	 	    l_product_table(j) := l_stripped_num_table(i);
		ELSE
		    -- Even numbered digit.  Multiply digit by 2 and store in the product table.
		    -- Numbers beyond 5 result in 2 digits when multiplied by 2. So handled seperately.
	            IF (l_stripped_num_table(i) >= 5)
		    THEN
		         j := j+1;
	 		 l_product_table(j) := 1;
		         j := j+1;
	 		 l_product_table(j) := (l_stripped_num_table(i) - 5) * 2;
		    ELSE
		         j := j+1;
	 		 l_product_table(j) := l_stripped_num_table(i) * 2;
		    END IF;
		END IF;
	END LOOP;

	-- Sum up the product table's digits
	FOR k in 1..j LOOP
		l_product_tab_sum := l_product_tab_sum + l_product_table(k);
	END LOOP;

	l_mod10_check_digit := mod( (10 - mod( l_product_tab_sum, 10)), 10);

	-- If actual check digit and check_digit after mod10 don't match, the credit card is an invalid one.
	IF ( l_mod10_check_digit <> l_actual_cc_check_digit)
	THEN
		arp_util.debug('Card is Valid');
		arp_util.debug('ar_irec_payments_pkg.is_credit_card_number_valid()-');
		return(0);
	ELSE
		arp_util.debug('Card is not Valid');
		arp_util.debug('ar_irec_payments_pkg.is_credit_card_number_valid()-');
		return(1);
	END IF;

END is_credit_card_number_valid;


/*========================================================================
 | PUBLIC function get_credit_card_type
 |
 | DESCRIPTION
 |      Determines for a given credit card number the credit card type.
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      credit_card_number   IN      Credit card number
 |
 | RETURNS
 |      credit_card type (based on lookup type  AR_IREC_CREDIT_CARD_TYPE
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-JAN-2001           O Steinmeier      Created
 | 11-AUG-2008          avepati             Bug 6493495 - TST1203.XB5.QA: CREDIT CARD PAYMENT NOT WORKING
 |
 *=======================================================================*/
FUNCTION get_credit_card_type(  p_credit_card_number IN  VARCHAR2 )
         RETURN VARCHAR2 IS

  /*-----------------------------------------------------------------------+
 | Use for file debug or standard output debug                           |
 +-----------------------------------------------------------------------*/

--   arp_standard.debug('AR_IREC_PAYMENTS.get_credit_card_type()+');

--   arp_standard.debug(' p_credit_card_number :' || p_credit_card_number);

   l_card_issuer     iby_creditcard_issuers_b.card_issuer_code%TYPE;
   l_issuer_range   iby_cc_issuer_ranges.cc_issuer_range_id%TYPE;
   l_card_prefix    iby_cc_issuer_ranges.card_number_prefix%TYPE;
   l_digit_check    iby_creditcard_issuers_b.digit_check_flag%TYPE;

 CURSOR c_range
    (ci_card_number IN iby_creditcard.ccnumber%TYPE,
     ci_card_len IN NUMBER)
    IS
      SELECT cc_issuer_range_id, r.card_issuer_code,
        card_number_prefix, NVL(digit_check_flag,'N')
      FROM iby_cc_issuer_ranges r, iby_creditcard_issuers_b i
      WHERE (card_number_length = ci_card_len)
        AND (INSTR(ci_card_number,card_number_prefix) = 1)
        AND (r.card_issuer_code = i.card_issuer_code);
  BEGIN
    IF (c_range%ISOPEN) THEN CLOSE c_range; END IF;

    OPEN c_range(p_credit_card_number,LENGTH(p_credit_card_number));
    FETCH c_range INTO l_issuer_range, l_card_issuer,
      l_card_prefix, l_digit_check;
    CLOSE c_range;

--   arp_standard.debug(' l_card_issuer  :' || l_card_issuer);

    IF (l_card_issuer IS NULL) THEN
      l_card_issuer := 'UNKNOWN';
      l_digit_check := 'N';
    END IF;
    RETURN  l_card_issuer;
END get_credit_card_type;

/*========================================================================
 | PUBLIC function get_exchange_rate
 |
 | DESCRIPTION
 |      Returns exchange rate information
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 |
 |
 |
 | RETURNS
 |
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 27-FEB-2001           O Steinmeier      Created
 |
 *=======================================================================*/

 PROCEDURE get_exchange_rate(
              p_trx_currency_code   IN VARCHAR2,
              p_trx_exchange_rate   IN NUMBER,
              p_def_exchange_rate_date  IN DATE DEFAULT trunc(SYSDATE),
              p_exchange_rate       OUT NOCOPY NUMBER,
              p_exchange_rate_type  OUT NOCOPY VARCHAR2,
              p_exchange_rate_date  OUT NOCOPY DATE) IS


   l_fixed_rate     VARCHAR2(30);
   l_procedure_name VARCHAR2(30);
   l_debug_info	    VARCHAR2(200);

 BEGIN

   l_procedure_name := '.get_exchange_rate';

   -- By default set the exchange rate date to the proposed default.
   --------------------------------------------------------------------------------
   l_debug_info := 'Set the exchange rate date to the proposed default';
   --------------------------------------------------------------------------------
   p_exchange_rate_date := p_def_exchange_rate_date;

   -- first check if invoice is in foreign currency:

   if (p_trx_currency_code = arp_global.functional_currency) then

     -- trx currency is base currency; no exchange rate needed.
     --------------------------------------------------------------------------------
     l_debug_info := 'Transaction currency is base currency; no exchange rate needed';
     --------------------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Trx currency is functional --> no exchange rate');
     END IF;

     p_exchange_rate := NULL;
     p_exchange_rate_type := NULL;
     p_exchange_rate_date := NULL;

     RETURN;

   end if;

   -- check if currencies have fixed-rate relationship
   --------------------------------------------------------------------------------
   l_debug_info := 'Check if currencies have fixed-rate relationship';
   --------------------------------------------------------------------------------
   l_fixed_rate := gl_currency_api.is_fixed_rate(
                         p_trx_currency_code,
                         arp_global.functional_currency,
                         p_exchange_rate_date);

   if l_fixed_rate = 'Y' then
     --------------------------------------------------------------------------
     l_debug_info := 'Exchange rate is fixed';
     --------------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Fixed Rate');
     END IF;

     p_exchange_rate_type := 'EMU FIXED';

     /* no need to get rate; rct api will get it anyway

     p_exchange_rate := arpcurr.getrate
             (p_trx_currency_code,
              arp_global.functional_currency,
              p_exchange_rate_date,
              p_exchange_rate_type);

     */

     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Rate = ' || to_char(p_exchange_rate));
     END IF;

   else  -- exchange rate is not fixed --> check profile for default type

     -------------------------------------------------------------------------------------
     l_debug_info := 'Exchange rate is not fixed - check profile option for default type';
     -------------------------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('No Fixed Rate');
     END IF;
     p_exchange_rate_type := fnd_profile.value('AR_DEFAULT_EXCHANGE_RATE_TYPE');

     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Profile option default exch rate type: '|| p_exchange_rate_type);
     END IF;

     if (p_exchange_rate_type IS NOT NULL) then

       -- try to get exchange rate from GL for this rate type
       -------------------------------------------------------------------------------------------
       l_debug_info := 'Exchange rate type obtained from profile option - get exchange rate from GL';
       -------------------------------------------------------------------------------------------
       p_exchange_rate :=  arpcurr.getrate
               (p_trx_currency_code,
                arp_global.functional_currency,
                p_exchange_rate_date,
                p_exchange_rate_type);

       IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug('Rate = ' || to_char(p_exchange_rate));
       END IF;

       if p_exchange_rate = -1 then -- no rate found in GL

         -------------------------------------------------------------------------------------------
         l_debug_info := 'Exchange rate not found in GL- use invoice exchange rate';
         -------------------------------------------------------------------------------------------
         IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug('no conversion rate found... using trx rate');
         END IF;

         p_exchange_rate_type := 'User';
         p_exchange_rate := p_trx_exchange_rate;

       else -- rate was successfully derived --> null it out so
            -- rct api can rederive it (it doesn't allow a derivable rate
            -- to be passed in!)

           p_exchange_rate := NULL;


       end if;

     else -- rate type profile is not set --> use invoice exchange rate
       -------------------------------------------------------------------------------------------
       l_debug_info := 'Rate type profile not set - use invoice exchange rate';
       -------------------------------------------------------------------------------------------
       p_exchange_rate_type := 'User';
       p_exchange_rate := p_trx_exchange_rate;

     end if;

   end if; -- fixed/non-fixed rate case

     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Leaving get_exchange_rate: ');
        arp_standard.debug('p_exchange_rate_type = ' || p_exchange_rate_type);
        arp_standard.debug('p_exchange_rate      = ' || to_char(p_exchange_rate));
     END IF;

 EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Transaction Currency Code: '||p_trx_currency_code);
      write_debug_and_log('- Transaction Exchange Rate: '||p_trx_exchange_rate);
      write_debug_and_log('- Exchange Rate found: '||p_exchange_rate);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

 END get_exchange_rate;


/*========================================================================
 | PUBLIC function get_payment_information
 |
 | DESCRIPTION
 |      Returns payment method and remittance bank information
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 |
 |
 |
 | RETURNS
 |
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-FEB-2001           O Steinmeier      Created
 | 26-APR-2004           vnb               Bug # 3467287 - Customer Site ID made an input
 |										   parameter.
 | 22-JUN-2007		 mbolli		   Bug#6109909 - Not using 'Payment Method' set at
 |					     customer/site level
 | 19-AUG-2009   nkanchan   Bug # 8780501 - Payments are failing
 |
 *=======================================================================*/

PROCEDURE  get_payment_information(
                  p_customer_id		    IN NUMBER,
                  p_site_use_id             IN NUMBER DEFAULT NULL,
		  p_payment_schedule_id     IN NUMBER,
                  p_payment_instrument      IN VARCHAR2,
                  p_trx_date                IN DATE,
         	  p_currency_code           OUT NOCOPY VARCHAR2,
                  p_exchange_rate           OUT NOCOPY VARCHAR2,
          	  p_receipt_method_id       OUT NOCOPY NUMBER,
           	  p_remit_bank_account_id   OUT NOCOPY NUMBER,
           	  p_receipt_creation_status OUT NOCOPY VARCHAR2,
                  p_trx_number              OUT NOCOPY VARCHAR2,
		  p_payment_channel_code    OUT NOCOPY VARCHAR2
                  ) IS


CURSOR payment_method_info_cur IS
   SELECT rm.receipt_method_id receipt_method_id, rm.payment_channel_code payment_channel_code,
          rc.creation_status receipt_creation_status
   FROM   ar_system_parameters sp,
          ar_receipt_classes rc,
          ar_receipt_methods rm
   WHERE  rm.receipt_method_id = decode(p_payment_instrument,                        /* J Rautiainen ACH Implementation */
                                       'BANK_ACCOUNT', sp.irec_ba_receipt_method_id, /* J Rautiainen ACH Implementation */
                                        sp.irec_cc_receipt_method_id)                /* J Rautiainen ACH Implementation */
      AND rm.receipt_class_id = rc.receipt_class_id;

  --Bug3186314: Cursor to get the payment method at customer/site level.
  CURSOR cust_payment_method_info_cur(p_siteuseid NUMBER, p_currcode VARCHAR2) IS
   SELECT arm.receipt_method_id receipt_method_id, arm.payment_channel_code payment_channel_code,
          arc.creation_status receipt_creation_status
   FROM      ar_receipt_methods         arm,
             ra_cust_receipt_methods    rcrm,
             ar_receipt_method_accounts arma,
             ce_bank_acct_uses_ou_v          aba,
             ce_bank_accounts           cba,
             ar_receipt_classes         arc
   WHERE     arm.receipt_method_id = rcrm.receipt_method_id
   AND       arm.receipt_method_id = arma.receipt_method_id
   AND       arm.receipt_class_id  = arc.receipt_class_id
   AND       rcrm.customer_id      = p_customer_id
   AND       arma.remit_bank_acct_use_id = aba.bank_acct_use_id
   AND       aba.bank_account_id = cba.bank_account_id
   AND
             (
                 NVL(rcrm.site_use_id,
                     p_siteuseid)   = p_siteuseid
               OR
                 (
                        p_siteuseid IS NULL
                   AND  rcrm.site_use_id  IS NULL
                 )
             )
--Bug#6109909
   --AND       rcrm.primary_flag          = 'Y'
   AND       (
                 cba.currency_code    =
                             p_currcode OR
                 cba.receipt_multi_currency_flag = 'Y'
             )
   AND      (
                 (    p_payment_instrument = 'BANK_ACCOUNT'
--Bug 6024713: Choose 'NONE' if arm.payment_type_code is NULL
--Bug#6109909:
      -- In 11i The 'PaymentMethod' in UI maps to 'payment_type_code' column of table ar_receipts_methods
      -- and in R12, it maps to 'payment_channel_code' whose values are taken from IBY sources.
      -- In R12, the 'payment_type_code' is 'NONE' for new records.
      -- AND In R12, Here we are not handling the code for the other payment Methods like Bills Receivable, Debit Card etc..,

             --  and nvl(arm.payment_type_code, 'NONE') <> 'CREDIT_CARD'
                  and arm.payment_channel_code <> 'CREDIT_CARD'
                  and arc.remit_flag = 'Y'
                  and arc.confirm_flag = 'N')
             OR  (    p_payment_instrument <> 'BANK_ACCOUNT'
    --Bug#6109909
                --and nvl(arm.payment_type_code, 'NONE') = 'CREDIT_CARD')
                  and arm.payment_channel_code = 'CREDIT_CARD')
            )

  -- Bug#6109909:
     -- In R12,Currency code is not mandatory on the customer bank account and so removing the
     -- below condition.
     -- Observations for the below condition, if it requires in future:
     -- a. The where caluse criteria 'party_id = p_customer_id' should be replaced
     --    with 'cust_account_id = p_customer_id'
     -- b. For 'AUTOMATIC' creation methods, Don't validate the currencyCode for
     -- 'Credit Card' instrucment types. Here validate only for 'BankAccount'

  /*

   AND      ( arc.creation_method_code = 'MANUAL' or
            ( arc.creation_method_code = 'AUTOMATIC' and
--Bug 4947418: Modified the following query as ar_customer_bank_accounts_v
--has been obsoleted in r12.
              p_currcode in (select currency_code from
		iby_fndcpt_payer_assgn_instr_v
		where party_id=p_customer_id)))
   */


   -- AND       aba.set_of_books_id = arp_trx_global.system_info.system_parameters.set_of_books_id
   AND       TRUNC(nvl(aba.end_date,
                         p_trx_date)) >=
             TRUNC(p_trx_date)
--Bug 6024713: Added TRUNC for the left side for the below 3 criterias
   AND       TRUNC(p_trx_date) between
                      TRUNC(nvl(
                                   arm.start_date,
                                  p_trx_date))
                  and TRUNC(nvl(
                                  arm.end_date,
                                  p_trx_date))
   AND       TRUNC(p_trx_date) between
                      TRUNC(nvl(
                                   rcrm.start_date,
                                  p_trx_date))
                  and TRUNC(nvl(
                                  rcrm.end_date,
                                  p_trx_date))
   AND       TRUNC(p_trx_date) between
                      TRUNC(arma.start_date)
                  and TRUNC(nvl(
                                  arma.end_date,
                                  p_trx_date))
              ORDER BY rcrm.primary_flag DESC;

--Bug 6339265 : Cursor to get CC Payment Method set in the profile OIR_CC_PMT_METHOD.
 CURSOR cc_profile_pmt_method_info_cur IS
  SELECT arm.receipt_method_id receipt_method_id,
    arm.payment_channel_code payment_channel_code,
    arc.creation_status receipt_creation_status
  FROM ar_receipt_methods arm,
    ar_receipt_method_accounts arma,
    ce_bank_acct_uses_ou_v aba,
    ce_bank_accounts       cba,
    ar_receipt_classes arc
  WHERE arm.payment_channel_code = 'CREDIT_CARD'
    AND arm.receipt_method_id = NVL( to_number(fnd_profile.VALUE('OIR_CC_PMT_METHOD')), arm.receipt_method_id)
    AND arm.receipt_method_id = arma.receipt_method_id
    AND arm.receipt_class_id = arc.receipt_class_id
    AND arma.remit_bank_acct_use_id = aba.bank_acct_use_id
    AND aba.bank_account_id = cba.bank_account_id
    AND (cba.currency_code = p_currency_code OR cba.receipt_multi_currency_flag = 'Y')
    AND TRUNC(nvl(aba.end_date,p_trx_date)) >= TRUNC(p_trx_date)
    AND TRUNC(p_trx_date) BETWEEN TRUNC(nvl(arm.start_date,   p_trx_date)) AND TRUNC(nvl(arm.end_date,   p_trx_date))
    AND TRUNC(p_trx_date) BETWEEN TRUNC(arma.start_date) AND TRUNC(nvl(arma.end_date,   p_trx_date));

  --Bug 6339265 : Cursor to get Bank Acount Payment Method set in the profile OIR_BA_PMT_METHOD.
 CURSOR ba_profile_pmt_method_info_cur IS
  SELECT arm.receipt_method_id receipt_method_id,
    arm.payment_channel_code payment_channel_code,
    arc.creation_status receipt_creation_status
  FROM ar_receipt_methods arm,
    ar_receipt_method_accounts arma,
    ce_bank_acct_uses_ou_v aba,
    ce_bank_accounts       cba,
    ar_receipt_classes arc
  WHERE NVL(arm.payment_channel_code,'NONE') <> 'CREDIT_CARD'
    AND arm.receipt_method_id = NVL( to_number(fnd_profile.VALUE('OIR_BA_PMT_METHOD')), arm.receipt_method_id)
    AND arm.receipt_method_id = arma.receipt_method_id
    AND arm.receipt_class_id = arc.receipt_class_id
    AND arma.remit_bank_acct_use_id = aba.bank_acct_use_id
    AND aba.bank_account_id = cba.bank_account_id
    AND (cba.currency_code = p_currency_code OR cba.receipt_multi_currency_flag = 'Y')
    AND TRUNC(nvl(aba.end_date,p_trx_date)) >= TRUNC(p_trx_date)
    AND TRUNC(p_trx_date) BETWEEN TRUNC(nvl(arm.start_date,   p_trx_date)) AND TRUNC(nvl(arm.end_date,   p_trx_date))
    AND TRUNC(p_trx_date) BETWEEN TRUNC(arma.start_date) AND TRUNC(nvl(arma.end_date,   p_trx_date));

CURSOR payment_schedule_info_cur IS
   SELECT customer_site_use_id, invoice_currency_code, exchange_rate,trx_number
   FROM   ar_payment_schedules
   WHERE  payment_schedule_id = p_payment_schedule_id;

   payment_method_info    payment_method_info_cur%ROWTYPE;
   payment_schedule_info  payment_schedule_info_cur%ROWTYPE;
   cust_payment_method_info  cust_payment_method_info_cur%ROWTYPE;
   cc_profile_pmt_method_info cc_profile_pmt_method_info_cur%ROWTYPE;
   ba_profile_pmt_method_info ba_profile_pmt_method_info_cur%ROWTYPE;

  l_customer_id		RA_CUST_RECEIPT_METHODS.CUSTOMER_ID%TYPE;
  l_site_use_id		RA_CUST_RECEIPT_METHODS.SITE_USE_ID%TYPE;
  l_currency_code	AR_PAYMENT_SCHEDULES_ALL.INVOICE_CURRENCY_CODE%TYPE;

  l_procedure_name VARCHAR2(30);
  l_debug_info	   VARCHAR2(200);

BEGIN

   l_procedure_name := '.get_payment_information';

   --------------------------------------------------------------------
   l_debug_info := 'Get payment schedule information';
   --------------------------------------------------------------------
   OPEN payment_schedule_info_cur;
   FETCH payment_schedule_info_cur INTO payment_schedule_info;
   close payment_schedule_info_cur;

   l_currency_code := payment_schedule_info.invoice_currency_code;
   l_site_use_id   := payment_schedule_info.customer_site_use_id;
   p_trx_number    := payment_schedule_info.trx_number;
   p_exchange_rate := payment_schedule_info.exchange_rate;

   -- ### required change: error handling
   -- ### in case the query fails.

  --Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
  if (p_payment_schedule_id is null ) then
    -- this is the case for multiple invoices.
    ------------------------------------------------------------------------
    l_debug_info := 'There are multiple invoices: get customer information';
    ------------------------------------------------------------------------
    BEGIN
      select customer_id,customer_site_use_id,currency_code into l_customer_id,l_site_use_id,l_currency_code
      from AR_IREC_PAYMENT_LIST_GT
      where customer_id = p_customer_id
      and customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id);
      EXCEPTION
        when others then
          IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug('There may be invoices with different sites');
          END IF;
    END;
    if ( l_customer_id is null ) then
     --Code should not come here ideally
     BEGIN
        select currency_code into l_currency_code
        from AR_IREC_PAYMENT_LIST_GT
        group by currency_code;
        EXCEPTION
          when others then
            IF (PG_DEBUG = 'Y') THEN
              arp_standard.debug('There may be invoices with different currencies');
            END IF;
      END;
    end if;
  end if;

  -- IF Customer Site Use Id is -1 then it is to be set as null
  IF ( l_site_use_id = -1 ) THEN
    l_site_use_id := NULL;
  END IF;

    IF (p_payment_instrument <> 'BANK_ACCOUNT') THEN
	  ---------------------------------------------------------------------------------
	  l_debug_info := 'Get payment method information from the OIR_CC_PMT_METHOD profile';
	  ---------------------------------------------------------------------------------
	  IF (fnd_profile.VALUE('OIR_CC_PMT_METHOD') IS NOT NULL AND fnd_profile.VALUE('OIR_CC_PMT_METHOD') <> 'DISABLED') THEN

            BEGIN

		  OPEN  cc_profile_pmt_method_info_cur;
		  FETCH cc_profile_pmt_method_info_cur INTO cc_profile_pmt_method_info;

	      /* If CC Payment Method set is NULL or DISABLED or an invalid payment method, it returns NO rows */

		  IF cc_profile_pmt_method_info_cur%FOUND THEN
		    p_receipt_creation_status	:=  cc_profile_pmt_method_info.receipt_creation_status;
		    p_receipt_method_id		:=  cc_profile_pmt_method_info.receipt_method_id;
                    p_payment_channel_code  :=  cc_profile_pmt_method_info.payment_channel_code;
		  END IF;

		  CLOSE cc_profile_pmt_method_info_cur;

            EXCEPTION
              WHEN OTHERS THEN
                l_debug_info := 'Invalid Payment Method is Set in the profile OIR_CC_PMT_METHOD. Value in profile=' ||  fnd_profile.VALUE('OIR_CC_PMT_METHOD');
		     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info
                                            ||':ERROR =>'|| SQLERRM);
		     end if;
            END;

	  END IF;
  END IF;

  IF (p_payment_instrument <> 'CREDIT_CARD') THEN
	  ---------------------------------------------------------------------------------
	  l_debug_info := 'Get payment method information from the OIR_BA_PMT_METHOD profile';
	  ---------------------------------------------------------------------------------
	  IF (fnd_profile.VALUE('OIR_BA_PMT_METHOD') IS NOT NULL AND fnd_profile.VALUE('OIR_BA_PMT_METHOD') <> 'DISABLED') THEN

            BEGIN

		  OPEN  ba_profile_pmt_method_info_cur;
		  FETCH ba_profile_pmt_method_info_cur INTO ba_profile_pmt_method_info;

	      /* If BA Payment Method set is NULL or DISABLED or an invalid payment method, it returns NO rows */

		  IF ba_profile_pmt_method_info_cur%FOUND THEN
		    p_receipt_creation_status	:=  ba_profile_pmt_method_info.receipt_creation_status;
		    p_receipt_method_id		:=  ba_profile_pmt_method_info.receipt_method_id;
		    p_payment_channel_code  :=  ba_profile_pmt_method_info.payment_channel_code;
		  END IF;

		  CLOSE ba_profile_pmt_method_info_cur;

            EXCEPTION
              WHEN OTHERS THEN
                l_debug_info := 'Invalid Payment Method is Set in the profile OIR_BA_PMT_METHOD. Value in profile=' ||  fnd_profile.VALUE('OIR_BA_PMT_METHOD');
		     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info
                                            ||':ERROR =>'|| SQLERRM);
		     end if;
            END;

	  END IF;
  END IF;

  IF ( p_receipt_method_id IS NULL ) THEN

  ---------------------------------------------------------------------------------
  l_debug_info := 'Get payment method information from the relevant customer site';
  ---------------------------------------------------------------------------------
  OPEN  cust_payment_method_info_cur(l_site_use_id, l_currency_code);
  FETCH cust_payment_method_info_cur INTO cust_payment_method_info;

  IF cust_payment_method_info_cur%FOUND THEN
    p_receipt_creation_status := cust_payment_method_info.receipt_creation_status;
    p_receipt_method_id := cust_payment_method_info.receipt_method_id;
    p_payment_channel_code := cust_payment_method_info.payment_channel_code;
  END IF;
  CLOSE cust_payment_method_info_cur;
 END IF;

  if ( p_receipt_method_id is null ) then
    ----------------------------------------------------------------------------------------
    l_debug_info := 'Get payment method information from the customer at the account level';
    ----------------------------------------------------------------------------------------
    l_site_use_id := NULL;
    OPEN  cust_payment_method_info_cur(l_site_use_id, l_currency_code);
    FETCH cust_payment_method_info_cur INTO cust_payment_method_info;

    IF cust_payment_method_info_cur%FOUND THEN
      p_receipt_creation_status := cust_payment_method_info.receipt_creation_status;
      p_receipt_method_id := cust_payment_method_info.receipt_method_id;
      p_payment_channel_code := cust_payment_method_info.payment_channel_code;
    END IF;
    CLOSE cust_payment_method_info_cur;
  end if;

  if ( p_receipt_method_id is null ) then
    -- get from system parameters
    ----------------------------------------------------------------------------------------
    l_debug_info := 'Get payment method information from the system parameters';
    ----------------------------------------------------------------------------------------
    OPEN  payment_method_info_cur;
    FETCH payment_method_info_cur INTO payment_method_info;

    IF payment_method_info_cur%FOUND THEN
      p_receipt_creation_status := payment_method_info.receipt_creation_status;
      p_receipt_method_id := payment_method_info.receipt_method_id;
      p_payment_channel_code := payment_method_info.payment_channel_code;
    END IF;
    CLOSE payment_method_info_cur;
  end if;

  --Bug # 3467287 - p_site_use_id is made an input parameter.
  --p_site_use_id   := l_site_use_id;
  p_currency_code := l_currency_code;

EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Customer Id: '||p_customer_id);
      write_debug_and_log('- Customer Site Id: '||p_site_use_id);
      write_debug_and_log('- Receipt Method Id: '||p_receipt_method_id);
      write_debug_and_log('- Payment Schedule Id: '||p_payment_schedule_id);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END get_payment_information;

/*========================================================================
 | PUBLIC procedure update_expiration_date
 |
 | DESCRIPTION
 |      Updates credit card expiration date
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |      p_bank_account_id         Credit Card bank account id
 |      p_expiration_date	  New expiration date
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-FEB-2001           O Steinmeier      Created
 |
 | Removed code 'BANK_ACCOUNT_NUM = p_bank_account_num AND ' from select for bug # 9046643
 *=======================================================================*/
PROCEDURE update_expiration_date( p_bank_account_id     IN  NUMBER,
                                  p_expiration_date     IN  DATE,
                                  p_payment_instrument  IN VARCHAR2,
                                  p_branch_id			IN iby_ext_bank_accounts.BRANCH_ID%TYPE,
                                  p_bank_id			    IN iby_ext_bank_accounts.BANK_ID%TYPE,
                                  p_bank_account_num	IN iby_ext_bank_accounts.BANK_ACCOUNT_NUM%TYPE,
                                  p_currency			IN iby_ext_bank_accounts.CURRENCY_CODE%TYPE,
                                  p_object_version_number IN iby_ext_bank_accounts.OBJECT_VERSION_NUMBER%TYPE,
				  x_return_status       OUT NOCOPY VARCHAR,
				  x_msg_count           OUT NOCOPY NUMBER,
				  x_msg_data            OUT NOCOPY VARCHAR2) IS

   l_create_credit_card		IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
   l_ext_bank_acct_rec      IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
   l_result_rec			IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   l_procedure_name		VARCHAR2(30);
   l_acct_holder_name   	iby_ext_bank_accounts.BANK_ACCOUNT_NAME%TYPE;
   l_acct_type          	iby_ext_bank_accounts.BANK_ACCOUNT_TYPE%TYPE;
   l_start_date         	DATE;
BEGIN

l_procedure_name		     := '.update_expiration_date';

IF p_payment_instrument = 'CREDIT_CARD' THEN

        WRITE_DEBUG_AND_LOG('In CC expiration date update');
        l_create_credit_card.card_id         := p_bank_account_id ;
        l_create_credit_card.expiration_date := p_expiration_date;

        IBY_FNDCPT_SETUP_PUB.update_card(
	        p_api_version      => 1.0,
	        p_init_msg_list    => FND_API.G_TRUE,
	        p_commit           => FND_API.G_FALSE,
	        x_return_status    => x_return_status,
	        x_msg_count        => x_msg_count,
	        x_msg_data         => x_msg_data,
	        p_card_instrument  => l_create_credit_card,
	        x_response         => l_result_rec);


   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      fnd_log.string(fnd_log.LEVEL_STATEMENT,
                      G_PKG_NAME||l_procedure_name,
                      'ERROR IN UPDATING CREDIT CARD');
          fnd_log.string(fnd_log.LEVEL_STATEMENT,
                      G_PKG_NAME||l_procedure_name,l_result_rec.result_code);
      end if;
      x_msg_data      := l_result_rec.result_code;
      x_return_status := FND_API.G_RET_STS_ERROR;
      write_error_messages(x_msg_data, x_msg_count);
    END IF;
ELSE

        WRITE_DEBUG_AND_LOG('In BA expiration date update');

        SELECT BANK_ACCOUNT_NAME, BANK_ACCOUNT_TYPE, START_DATE INTO l_acct_holder_name, l_acct_type, l_start_date
	  FROM IBY_EXT_BANK_ACCOUNTS WHERE EXT_BANK_ACCOUNT_ID = p_bank_account_id AND BRANCH_ID = p_branch_id AND BANK_ID = p_bank_id
	  AND CURRENCY_CODE = p_currency AND OBJECT_VERSION_NUMBER = p_object_version_number;
        l_ext_bank_acct_rec.branch_id               := p_branch_id;
        l_ext_bank_acct_rec.bank_id                 := p_bank_id;
        l_ext_bank_acct_rec.bank_account_num        := p_bank_account_num;
        l_ext_bank_acct_rec.currency                := p_currency;
        l_ext_bank_acct_rec.object_version_number   := p_object_version_number;
        l_ext_bank_acct_rec.bank_account_id         := p_bank_account_id;
        l_ext_bank_acct_rec.end_date                := p_expiration_date;
	  l_ext_bank_acct_rec.bank_account_name       := l_acct_holder_name;
        l_ext_bank_acct_rec.acct_type               := l_acct_type;
        l_ext_bank_acct_rec.start_date              := l_start_date;

        WRITE_DEBUG_AND_LOG('p_branch_id'||p_branch_id||'p_bank_id'||p_bank_id||
                            'p_bank_account_num ' || p_bank_account_num ||
                            'p_object_version_number ' || p_object_version_number ||
                            'p_bank_account_id ' || p_bank_account_id ||
                            'p_currency ' || p_currency||' l_acct_holder_name '||l_acct_holder_name||
				    'l_acct_type '||l_acct_type||' l_start_date '||l_start_date);

        IBY_EXT_BANKACCT_PUB.update_ext_bank_acct(
                p_api_version       => 1.0,
                p_init_msg_list     => FND_API.G_TRUE,
                p_ext_bank_acct_rec => l_ext_bank_acct_rec,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                x_response          => l_result_rec);


   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      fnd_log.string(fnd_log.LEVEL_STATEMENT,
                      G_PKG_NAME||l_procedure_name,
                      'ERROR IN UPDATING BANK ACCOUNT');
          fnd_log.string(fnd_log.LEVEL_STATEMENT,
                      G_PKG_NAME||l_procedure_name,x_msg_data);
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      write_error_messages(x_msg_data, x_msg_count);
    END IF;
END IF;


EXCEPTION
WHEN OTHERS THEN
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Card Id: '||p_bank_account_id);
      write_debug_and_log('- Expiration Date: '||p_expiration_date);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);

      FND_MSG_PUB.ADD;

END;
/*========================================================================
 | PUBLIC function allow_payment
 |
 | DESCRIPTION
 |      Determines if payment schedule can be paid:
 |
 |   It will return TRUE if
 |
 |   - payment button is enabled via function security
 |     (need to define function)
 |   - the remaining balance of the payment schedule is > 0
 |   - a payment method has been defined in AR_SYSTEM_PARAMETERS
 |     for credit card payments
 |   - a bank account assignment in the currency of the invoice
 |     exists and is active.
 |
 |   Use this function to enable or disable the "Pay" button on
 |   the invoice and invoice activities pages.
 |
 |
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |      p_payment_schedule_id     Payment Schedule to be paid
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-FEB-2001           O Steinmeier      Created
 |
 *=======================================================================*/


FUNCTION allow_payment(p_payment_schedule_id IN NUMBER, p_customer_id IN NUMBER , p_customer_site_id IN NUMBER)  RETURN BOOLEAN IS

  l_ps_balance    NUMBER;
  l_bank_account_method   NUMBER;
  l_credit_card_method    NUMBER; /* J Rautiainen ACH Implementation */
  l_currency_code ar_payment_schedules.invoice_currency_code%type;
  l_class        ar_payment_schedules.class%TYPE;
  l_creation_status ar_receipt_classes.creation_status%TYPE;

BEGIN

  -- check that function security is allowing access to payment button

  IF NOT fnd_function.test('ARW_PAY_INVOICE') THEN
    RETURN FALSE;
  END IF;

  -- check trx type and balance: trx type must be debit item, balance > 0

  SELECT amount_due_remaining, class, invoice_currency_code
  INTO   l_ps_balance, l_class, l_currency_code
  FROM   ar_payment_schedules
  WHERE  payment_schedule_id = p_payment_schedule_id;
  --Bug 4161986 - Pay Icon does not appear in the ChargeBack and its activities page. Added the class CB(Chargeback)
  IF l_ps_balance <= 0
     OR l_class NOT IN ('INV', 'DEP', 'GUAR', 'DM', 'CB') THEN

     RETURN FALSE;

  END IF;

  -- verify that method is set up
  l_credit_card_method := is_credit_card_payment_enabled(p_customer_id , p_customer_site_id , l_currency_code) ;

  -- Bug 3338276
  -- If one-time payment is enabled, bank account payment is not enabled;
  -- Hence, the check for valid bank account payment methods can be defaulted to 0.
  -- Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.save_payment_instrument_info
  IF NOT ARI_UTILITIES.save_payment_instrument_info(p_customer_id , p_customer_site_id) THEN
    l_bank_account_method := 0;
  ELSE
    l_bank_account_method := is_bank_acc_payment_enabled(p_customer_id , p_customer_site_id , l_currency_code);
  END IF;

  IF   l_bank_account_method  = 0
   AND l_credit_card_method = 0
  THEN
    RETURN FALSE;

  END IF;

  RETURN TRUE;

END allow_payment;

-- cover function on top of allow_payments to allow usage in SQL statements.

FUNCTION payment_allowed(p_payment_schedule_id IN NUMBER,p_customer_id IN NUMBER , p_customer_site_id IN NUMBER) RETURN NUMBER IS
BEGIN
  if allow_payment(p_payment_schedule_id , p_customer_id , p_customer_site_id ) then
     return 1;
  else
     return 0;
  end if;
END payment_allowed;

/*========================================================================
 | PUBLIC procedure get_default_payment_instrument
 |
 | DESCRIPTION
 |      Return payment instrument information if one can be defaulted for the user
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      customer_id IN Customer Id to which credit cards are releated to
 |      customer_site_use_id IN Customer Site Use Id to which credit cards are releated to
 |	currency_code	IN	VARCHAR2
 |
 | RETURNS
 |      p_bank_account_num_masked Masked credit card number
 |      p_credit_card_type        Type of the credit card
 |      p_expiry_month            Credit card expiry month
 |      p_expiry_year             Credit card expiry year
 |      p_credit_card_expired     '1' if credit card has expired, '0' otherwise
 |      p_bank_account_id         Bank Account id of the credit card
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-JAN-2001           J Rautiainen      Created
 | 20-May-2004		 hikumar	   Added currencyCode
 | 26-Oct-2004       vnb           Bug 3944029 - Correct payment instrument to be picked at customer account level
 | 23-Dec-2004       vnb           Bug 3928412 - RA_CUSTOMERS obsolete;removed reference to it
 | 09-Nov-2009      avepati     Bug 9098662 - Able to make payments with end dated bank accounts
 *=======================================================================*/
PROCEDURE get_default_payment_instrument(p_customer_id             IN  NUMBER,
                                         p_customer_site_use_id    IN  NUMBER DEFAULT NULL,
                                         p_currency_code	   IN  VARCHAR2,
					 p_bank_account_num_masked OUT NOCOPY VARCHAR2,
                                         p_account_type            OUT NOCOPY VARCHAR2,
                                         p_expiry_month            OUT NOCOPY VARCHAR2,
                                         p_expiry_year             OUT NOCOPY VARCHAR2,
                                         p_credit_card_expired     OUT NOCOPY VARCHAR2,
                                         p_bank_account_id         OUT NOCOPY ce_bank_accounts.bank_account_id%TYPE,
                                         p_bank_branch_id          OUT NOCOPY ce_bank_accounts.bank_branch_id%TYPE,
                                         p_account_holder          OUT NOCOPY VARCHAR2,
                                         p_card_brand		   OUT NOCOPY VARCHAR2,
                                         p_cvv_code		   OUT NOCOPY VARCHAR2,
                                         p_conc_address		   OUT NOCOPY VARCHAR2,
                                         p_cc_bill_site_id  	   OUT NOCOPY NUMBER,
                                         p_instr_assignment_id	   OUT NOCOPY NUMBER,
                                         p_bank_party_id	   OUT NOCOPY NUMBER,
                                         p_branch_party_id	   OUT NOCOPY NUMBER,
                                         p_object_version_no	   OUT NOCOPY NUMBER
                                         ) IS

  cursor last_used_instr_cur  IS
              SELECT bank.masked_bank_account_num  bank_account_num_masked,
  bank.bank_account_type account_type,
  NULL expiry_month,
  NULL expiry_year,
  '0' credit_card_expired,
  u.instrument_id bank_account_id,
  bank.branch_id bank_branch_id,
  bank.bank_account_name account_holder,
  NULL cvv_code,
  NULL conc_address,
  NULL card_code,
  NULL party_site_id,
  u.instrument_payment_use_id instr_assignment_id,
  bank.bank_id bank_party_id,
  bank.branch_id branch_party_id,
  bank.object_version_number
FROM hz_cust_accounts cust,
  hz_party_preferences pp1,
  iby_external_payers_all p,
  iby_pmt_instr_uses_all u,
  iby_ext_bank_accounts bank,
  hz_organization_profiles bapr,
  hz_organization_profiles brpr,
  iby_account_owners ow
WHERE cust.cust_account_id = p_customer_id
 AND pp1.party_id = cust.party_id
 AND pp1.category = 'LAST_USED_PAYMENT_INSTRUMENT'
 AND pp1.preference_code = 'INSTRUMENT_ID'
 AND p.cust_account_id = p_customer_id
 AND p.party_id = cust.party_id
 AND (	(p.acct_site_use_id = p_customer_site_use_id) 	OR
	(p.acct_site_use_id IS NULL  AND decode(p_customer_site_use_id,   -1,   NULL,   p_customer_site_use_id) IS NULL)  )
 AND u.ext_pmt_party_id = p.ext_payer_id
 AND u.instrument_type = 'BANKACCOUNT'
 AND u.payment_flow = 'FUNDS_CAPTURE'
 AND u.instrument_id = pp1.value_number
 AND pp1.value_number = bank.ext_bank_account_id(+)
 AND (  decode(bank.currency_code,   NULL,   'Y',   'N')='Y'  OR bank.currency_code = p_currency_code)
 AND bank.bank_id = bapr.party_id(+)
 AND bank.branch_id = brpr.party_id(+)
 AND TRUNC(sysdate) BETWEEN nvl(TRUNC(bapr.effective_start_date),   sysdate -1)  AND nvl(TRUNC(bapr.effective_end_date),   sysdate + 1)
 AND TRUNC(sysdate) BETWEEN nvl(TRUNC(brpr.effective_start_date),   sysdate -1)  AND nvl(TRUNC(brpr.effective_end_date),   sysdate + 1)
 AND bank.ext_bank_account_id = ow.ext_bank_account_id(+)
 AND ow.primary_flag(+) = 'Y'
 AND nvl(TRUNC(bank.end_date),   sysdate + 10) >= TRUNC(sysdate)  --bug 9098662


UNION ALL


 SELECT c.CARD_NUMBER bank_account_num_masked,
  c.CARD_ISSUER_NAME account_type,
  null expiry_month,
  null expiry_year,
  decode(c.CARD_EXPIRED_FLAG,'Y','1','0') credit_card_expired,
  c.INSTRUMENT_ID bank_account_id,
  1 bank_branch_id,
  nvl(c.CARD_HOLDER_NAME,   hzcc.party_name) account_holder,
  NULL cvv_code,
  arp_addr_pkg.format_address(loc.address_style,   loc.address1,   loc.address2,   loc.address3,   loc.address4,   loc.city,   loc.county,   loc.state,   loc.province,   loc.postal_code,   terr.territory_short_name) conc_address,
  c.CARD_ISSUER_CODE card_code,
  psu.party_site_id,
  c.INSTR_ASSIGNMENT_ID,
  NULL bank_party_id,
  NULL branch_party_id,
  NULL object_version_number
FROM hz_cust_accounts cust,
  hz_party_preferences pp1,
  iby_external_payers_all p,
  IBY_FNDCPT_PAYER_ASSGN_INSTR_V c,
  hz_parties hzcc,
  hz_party_site_uses psu,
  hz_party_sites hps,
  hz_locations loc,
  fnd_territories_vl terr
WHERE cust.cust_account_id = p_customer_id
 AND cust.party_id = hzcc.party_id
 AND pp1.party_id = hzcc.party_id
 AND pp1.category = 'LAST_USED_PAYMENT_INSTRUMENT'
 AND pp1.preference_code = 'INSTRUMENT_ID'
 AND p.cust_account_id = p_customer_id
 AND p.party_id = hzcc.party_id
 AND (	(p.acct_site_use_id = p_customer_site_use_id)  	OR
	(p.acct_site_use_id IS NULL  AND decode(p_customer_site_use_id,   -1,   NULL,   p_customer_site_use_id) IS NULL)  )
 AND c.INSTRUMENT_TYPE  = 'CREDITCARD'
 AND c.instrument_id = pp1.value_number
 AND c.EXT_PAYER_ID = p.ext_payer_id
 AND c.CARD_BILLING_ADDRESS_ID = psu.party_site_use_id(+)
 AND psu.party_site_id = hps.party_site_id(+)
 AND hps.location_id = loc.location_id(+)
 AND loc.country = terr.territory_code(+);


 CURSOR bank_account_cur IS
	SELECT
		  u.instrument_type instrument_type,
		  bank.masked_bank_account_num bank_account_num_masked,
		  bank.bank_account_type account_type,
		  null expiry_month,
		  null expiry_year,
		  '0' credit_card_expired,
		  u.instrument_id bank_account_id,
		  bank.branch_id bank_branch_id,
		  bank.bank_account_name account_holder,
		  null cvv_code,
		  null conc_address,
		  null card_code,
		  null party_site_id,
		  u.instrument_payment_use_id instr_assignment_id,
		  bank.bank_id bank_party_id,
		  bank.branch_id branch_party_id,
		  bank.object_version_number
	FROM
		  hz_cust_accounts cust,
		  iby_external_payers_all p,
		  iby_pmt_instr_uses_all u,
		  iby_ext_bank_accounts bank,
		  hz_organization_profiles bapr,
		  hz_organization_profiles brpr,
		  iby_account_owners ow

	WHERE
		 cust.cust_account_id = p_customer_id
		 AND p.cust_account_id = cust.cust_account_id
		 AND p.party_id = cust.party_id
		 AND (
			(p.acct_site_use_id = p_customer_site_use_id)
				OR
			(p.acct_site_use_id IS NULL AND DECODE(p_customer_site_use_id, -1, NULL, p_customer_site_use_id) IS NULL)
		    )
		 AND u.ext_pmt_party_id = p.ext_payer_id
		 AND u.instrument_type='BANKACCOUNT'
		 AND u.payment_flow = 'FUNDS_CAPTURE'
		 AND u.instrument_id = bank.ext_bank_account_id(+)
		 AND ( decode(bank.currency_code,   NULL,   'Y',   'N')='Y' OR bank.currency_code = p_currency_code)
		 AND bank.bank_id = bapr.party_id(+)
		 AND bank.branch_id = brpr.party_id(+)
		 AND TRUNC(sysdate) BETWEEN nvl(TRUNC(bapr.effective_start_date),   sysdate -1)  AND nvl(TRUNC(bapr.effective_end_date),   sysdate + 1)
		 AND TRUNC(sysdate) BETWEEN nvl(TRUNC(brpr.effective_start_date),   sysdate -1)  AND nvl(TRUNC(brpr.effective_end_date),   sysdate + 1)
		 AND bank.ext_bank_account_id = ow.ext_bank_account_id(+)
		 AND ow.primary_flag(+) = 'Y'
		 AND nvl(TRUNC(ow.end_date),   sysdate + 10) > TRUNC(sysdate);

 CURSOR credit_card_cur IS
	SELECT
		  u.instrument_type instrument_type,
		  c.masked_cc_number bank_account_num_masked,
		  decode(i.card_issuer_code, NULL, ccunk.meaning, i.card_issuer_name) account_type,
		  null expiry_month,
		  null expiry_year,
		  '0' credit_card_expired,
		  u.instrument_id bank_account_id,
		  1 bank_branch_id,
		  NVL(c.chname,hzcc.party_name) account_holder,
		  NULL cvv_code,
		  arp_addr_pkg.format_address(loc.address_style,   loc.address1,   loc.address2,   loc.address3,   loc.address4,   loc.city,   loc.county,   loc.state,   loc.province,   loc.postal_code,   terr.territory_short_name) conc_address,
		  c.card_issuer_code card_code,
		  psu.party_site_id,
		  u.instrument_payment_use_id instr_assignment_id,
		  NULL bank_party_id,
		  NULL branch_party_id,
		  NULL object_version_number
	FROM
		  fnd_lookup_values_vl ccunk,
		  iby_creditcard c,
		  iby_creditcard_issuers_vl i,
		  iby_external_payers_all p,
		  iby_pmt_instr_uses_all u,
		  hz_parties hzcc,
		  hz_cust_accounts cust,
		  hz_party_site_uses psu,
		  hz_party_sites hps,
		  hz_locations loc,
		  fnd_territories_vl terr
	WHERE
		 cust.cust_account_id = p_customer_id
		 AND p.cust_account_id = cust.cust_account_id
		 AND p.party_id = cust.party_id
		 AND (
			(p.acct_site_use_id = p_customer_site_use_id)
				OR
			(p.acct_site_use_id IS NULL AND DECODE(p_customer_site_use_id, -1, NULL, p_customer_site_use_id) IS NULL)
		     )
		 AND u.ext_pmt_party_id = p.ext_payer_id
		 AND u.instrument_type = 'CREDITCARD'
		 AND u.payment_flow = 'FUNDS_CAPTURE'
		 AND u.instrument_id = c.instrid(+)
		 AND nvl(c.inactive_date,   sysdate + 10) > sysdate
		 AND c.card_issuer_code = i.card_issuer_code(+)
		 AND c.card_owner_id = hzcc.party_id(+)
		 AND c.addressid = psu.party_site_use_id(+)
		 AND psu.party_site_id = hps.party_site_id(+)
		 AND hps.location_id = loc.location_id(+)
		 AND loc.country = terr.territory_code(+)
		 AND ccunk.lookup_type = 'IBY_CARD_TYPES'
		 AND ccunk.lookup_code = 'UNKNOWN';


  bank_account_rec     bank_account_cur%ROWTYPE;
  credit_card_rec      credit_card_cur%ROWTYPE;
  last_used_instr_rec  last_used_instr_cur%ROWTYPE;


  l_ba_count           NUMBER := 0;
  l_cc_count           NUMBER := 0;
  l_result             ce_bank_accounts.bank_account_num%TYPE;
  l_payment_instrument VARCHAR2(100);

  x_return_status     VARCHAR2(100);
  x_cvv_use           VARCHAR2(100);
  x_billing_addr_use  VARCHAR2(100);
  x_msg_count         NUMBER;
  x_msg_data          VARCHAR2(100);

BEGIN

    get_payment_channel_attribs
    (
      p_channel_code => 'CREDIT_CARD',
      x_return_status  => x_return_status,
      x_cvv_use => x_cvv_use,
      x_billing_addr_use => x_billing_addr_use,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
     );

/*
If there are multiple BA and only 1 CC, we return the CC details
If there is 1 BA and multiple CC, we return the BA details
If there is 1 BA, 1CC we return the BA details

Return NULL values in the following cases:
1)If there are more than one BA and more than one CC
2)If no saved instrument exists
3)If there's only one saved instrument and it doesn't have address
*/

   OPEN last_used_instr_cur;
   FETCH last_used_instr_cur INTO last_used_instr_rec;

   IF last_used_instr_cur%FOUND THEN
	  --If there's a last used instrument, return the address and other details.
	  --But, if that instrument doesn't have a BilltositeID associated(i.e., no bill to address), we return empty values

     CLOSE last_used_instr_cur;

-- bank_branch_id will be always 1  for CC , --  bug 7712779

if(last_used_instr_rec.bank_branch_id = 1) then
    if(ar_irec_payments.is_credit_card_payment_enabled(p_customer_id , p_customer_site_use_id , p_currency_code) = 1) then
     p_bank_account_num_masked := last_used_instr_rec.bank_account_num_masked;
     p_credit_card_expired     := last_used_instr_rec.credit_card_expired;
     p_account_type            := last_used_instr_rec.account_type;
     p_expiry_month            := last_used_instr_rec.expiry_month;
     p_expiry_year             := last_used_instr_rec.expiry_year;
     p_bank_account_id         := last_used_instr_rec.bank_account_id;
     p_bank_branch_id          := last_used_instr_rec.bank_branch_id;
     p_account_holder          := last_used_instr_rec.account_holder;
     p_cvv_code		       := last_used_instr_rec.cvv_code;
     p_card_brand	       := last_used_instr_rec.card_code;
     p_conc_address	       := last_used_instr_rec.conc_address;
     p_cc_bill_site_id	       := last_used_instr_rec.party_site_id;
     p_instr_assignment_id     := last_used_instr_rec.instr_assignment_id;
     p_bank_party_id	       := last_used_instr_rec.bank_party_id;
     p_branch_party_id	       := last_used_instr_rec.branch_party_id;
     p_object_version_no       := last_used_instr_rec.object_version_number;
   end if;

   else
   -- bug 7712779

    if(ar_irec_payments.is_bank_acc_payment_enabled(p_customer_id , p_customer_site_use_id , p_currency_code)=1) then
     p_bank_account_num_masked := last_used_instr_rec.bank_account_num_masked;
     p_credit_card_expired     := last_used_instr_rec.credit_card_expired;
     p_account_type            := last_used_instr_rec.account_type;
     p_expiry_month            := last_used_instr_rec.expiry_month;
     p_expiry_year             := last_used_instr_rec.expiry_year;
     p_bank_account_id         := last_used_instr_rec.bank_account_id;
     p_bank_branch_id          := last_used_instr_rec.bank_branch_id;
     p_account_holder          := last_used_instr_rec.account_holder;
     p_cvv_code		       := last_used_instr_rec.cvv_code;
     p_card_brand	       := last_used_instr_rec.card_code;
     p_conc_address	       := last_used_instr_rec.conc_address;
     p_cc_bill_site_id	       := last_used_instr_rec.party_site_id;
     p_instr_assignment_id     := last_used_instr_rec.instr_assignment_id;
     p_bank_party_id	       := last_used_instr_rec.bank_party_id;
     p_branch_party_id	       := last_used_instr_rec.branch_party_id;
     p_object_version_no       := last_used_instr_rec.object_version_number;
    end if;

  end if;


     /* Bug 4744886 - When last used payment instrument is created without Address
        and if profile value now requires Address, then this procedure will return
        no default instrument found, so that it would be taken to Adv Pmt Page

	p_bank_branch_id is 1 only for Credit Cards
      */


    if(p_bank_branch_id = 1 and p_cc_bill_site_id is NULL
	     and (x_billing_addr_use ='REQUIRED') ) then
            p_bank_account_num_masked := '';
            p_account_type            := '';
            p_expiry_month            := '';
            p_expiry_year             := '';
            p_bank_account_id         := TO_NUMBER(NULL);
            p_bank_branch_id          := TO_NUMBER(NULL);
            p_credit_card_expired     := '';
            p_account_holder          := '';
            p_card_brand	      := '';
            p_cvv_code		      := '';
            p_conc_address	      := '';
            p_cc_bill_site_id	      := TO_NUMBER(NULL);
            p_instr_assignment_id     := TO_NUMBER(NULL);
            p_bank_party_id	      := TO_NUMBER(NULL);
            p_branch_party_id	      := TO_NUMBER(NULL);
            p_object_version_no	      := TO_NUMBER(NULL);
     END IF;


   ELSE
     --If there's NO last used instrument

     CLOSE last_used_instr_cur;

     FOR bank_account_rec IN bank_account_cur LOOP

              --  bug 7712779

     	       if(ar_irec_payments.is_bank_acc_payment_enabled(p_customer_id , p_customer_site_use_id , p_currency_code) = 0) then
                    EXIT;
	       end if;

		--If there are any BA, in the first iteration read those values.
		--From 2nd iteration, maintain a count of the BA and CC existing

	       IF (l_ba_count = 0) THEN
		     l_payment_instrument      :='BANKACCOUNT';
		     p_bank_account_num_masked := bank_account_rec.bank_account_num_masked;
		     p_credit_card_expired     := bank_account_rec.credit_card_expired;
		     p_account_type            := bank_account_rec.account_type;
		     p_expiry_month            := bank_account_rec.expiry_month;
		     p_expiry_year             := bank_account_rec.expiry_year;
		     p_bank_account_id         := bank_account_rec.bank_account_id;
		     p_bank_branch_id          := bank_account_rec.bank_branch_id;
		     p_account_holder          := bank_account_rec.account_holder;
		     p_card_brand	       := '';
		     p_cvv_code		       := '';
		     p_conc_address	       := '';
		     p_cc_bill_site_id	       := '';
		     p_instr_assignment_id     := bank_account_rec.instr_assignment_id;
		     p_bank_party_id	       := bank_account_rec.bank_party_id;
		     p_branch_party_id	       := bank_account_rec.branch_party_id;
		     p_object_version_no       := bank_account_rec.object_version_number;
	       END IF;

	       l_ba_count                := l_ba_count + 1;

		IF(l_ba_count > 1) THEN
	  	     EXIT;
		END IF;

     END LOOP;

     FOR credit_card_rec IN credit_card_cur LOOP

          --  bug 7712779

     		if(ar_irec_payments.is_credit_card_payment_enabled(p_customer_id , p_customer_site_use_id , p_currency_code)=0) then
                      EXIT;
		end if;

	       IF(l_ba_count <>1 AND l_cc_count = 0) THEN
		     l_payment_instrument      := 'CREDITCARD';
		     p_bank_account_num_masked := bank_account_rec.bank_account_num_masked;
		     p_credit_card_expired     := bank_account_rec.credit_card_expired;
		     p_account_type            := bank_account_rec.account_type;
		     p_expiry_month            := bank_account_rec.expiry_month;
		     p_expiry_year             := bank_account_rec.expiry_year;
		     p_bank_account_id         := bank_account_rec.bank_account_id;
		     p_bank_branch_id          := bank_account_rec.bank_branch_id;
		     p_account_holder          := bank_account_rec.account_holder;
		     p_card_brand	       := bank_account_rec.card_code;
		     p_cvv_code		       := bank_account_rec.cvv_code;
		     p_conc_address	       := bank_account_rec.conc_address;
		     p_cc_bill_site_id	       := bank_account_rec.party_site_id;
		     p_instr_assignment_id     := bank_account_rec.instr_assignment_id;
		     p_bank_party_id	       := '';
		     p_branch_party_id	       := '';
		     p_object_version_no       := '';
		END IF;

		l_cc_count                := l_cc_count + 1;

		IF(l_cc_count > 1) THEN
			EXIT;
		END IF;
     END LOOP;


     IF (   (l_payment_instrument = 'BANKACCOUNT'  AND l_ba_count > 1)
	 OR (l_payment_instrument = 'CREDITCARD'   AND l_cc_count > 1)
	 OR (l_payment_instrument IS NULL)
	 OR (p_bank_branch_id = 1 and p_cc_bill_site_id is NULL
	     and x_billing_addr_use ='REQUIRED')
	) THEN
       p_bank_account_num_masked := '';
       p_account_type            := '';
       p_expiry_month            := '';
       p_expiry_year             := '';
       p_bank_account_id         := TO_NUMBER(NULL);
       p_bank_branch_id          := TO_NUMBER(NULL);
       p_credit_card_expired     := '';
       p_account_holder          := '';
       p_card_brand		 := '';
       p_cvv_code		 := '';
       p_conc_address	         := '';
       p_cc_bill_site_id	 := TO_NUMBER(NULL);
       p_instr_assignment_id     := TO_NUMBER(NULL);
       p_bank_party_id	         := '';
       p_branch_party_id	 := '';
       p_object_version_no       := '';
     END IF;

   END IF;

END get_default_payment_instrument;






/*========================================================================
 | PUBLIC function is_credit_card_expired
 |
 | DESCRIPTION
 |      Determines if a given credit card expiration date has passed.
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |      This function compares given month and year in the given parameter
 |      to the month and year of the current date.
 |
 | PARAMETERS
 |      p_expiration_date   IN   Credit card expiration date
 |
 | RETURNS
 |      1     if credit card has expired
 |      0     if credit card has not expired
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Feb-2001           Jani Rautiainen   Created
 |
 *=======================================================================*/
FUNCTION is_credit_card_expired(  p_expiration_date IN  DATE ) RETURN NUMBER IS

  CURSOR current_date_cur IS
    select to_char(to_number(to_char(sysdate,'MM'))) current_month,
           to_char(sysdate,'YYYY') current_year
    from dual;

  current_date_rec     current_date_cur%ROWTYPE;

BEGIN

  OPEN current_date_cur;
  FETCH current_date_cur INTO current_date_rec;
  CLOSE current_date_cur;

  IF to_number(to_char(p_expiration_date,'YYYY')) < to_number(current_date_rec.current_year)
     OR (to_number(to_char(p_expiration_date,'YYYY')) = to_number(current_date_rec.current_year)
         AND  to_number(to_char(p_expiration_date,'MM')) < to_number(current_date_rec.current_month)) THEN
     return 1; --TRUE;
  else
     return 0; --FALSE
  end if;

END is_credit_card_expired;

/*========================================================================
 | PUBLIC procedure store_last_used_ba
 |
 | DESCRIPTION
 |      Stores the last used bank account
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_customer_id      IN  NUMBER
 |      p_bank_account_id  IN  NUMBER
 |	p_instr_type	   IN  VARCHAR2 DEFAULT 'BA'
 |
 | RETURNS
 |      p_status	   OUT NOCOPY varchar2
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-May-2001           J Rautiainen      Created
 | 26-Oct-2005	 	 rsinthre          Bug 4673563 - Error in updating last used instrument
 *=======================================================================*/
PROCEDURE store_last_used_ba(p_customer_id     IN  NUMBER,
                             p_bank_account_id IN  NUMBER,
                             p_instr_type      IN  VARCHAR2 DEFAULT 'BA',
                             p_status          OUT NOCOPY VARCHAR2) IS
  l_msg_count             NUMBER;
  l_object_version_number NUMBER;
  l_msg_data              VARCHAR(2000);

  CURSOR customer_party_cur IS
    SELECT party_id
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_customer_id;

        CURSOR object_version_cur(p_party_id IN NUMBER, p_preference_code IN VARCHAR2) IS
           SELECT party_preference_id, object_version_number
        FROM   hz_party_preferences
        WHERE  party_id = p_party_id
        AND    category = 'LAST_USED_PAYMENT_INSTRUMENT'
        AND    preference_code = p_preference_code;

       customer_party_rec customer_party_cur%ROWTYPE;
      object_version_rec object_version_cur%ROWTYPE;

 BEGIN

   OPEN customer_party_cur;
   FETCH customer_party_cur INTO customer_party_rec;
   CLOSE customer_party_cur;

      OPEN object_version_cur(customer_party_rec.party_id,'INSTRUMENT_TYPE') ;
   FETCH object_version_cur INTO object_version_rec;
   CLOSE object_version_cur;

  SAVEPOINT STORE_INST;

    HZ_PREFERENCE_PUB.Put(
       p_party_id                 => customer_party_rec.party_id
  , p_category                  => 'LAST_USED_PAYMENT_INSTRUMENT'
  , p_preference_code          => 'INSTRUMENT_TYPE'
  , p_value_varchar2           => p_instr_type
  , p_module                   => 'IRECEIVABLES'
  , p_additional_value1        => NULL
  , p_additional_value2        => NULL
  , p_additional_value3        => NULL
  , p_additional_value4        => NULL
  , p_additional_value5        => NULL
  , p_object_version_number    => object_version_rec.object_version_number
  , x_return_status            => p_status
  , x_msg_count                => l_msg_count
  , x_msg_data                 => l_msg_data);

   IF ( p_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                 write_error_messages(l_msg_data, l_msg_count);
                  ROLLBACK TO STORE_INST;
                 RETURN;
          END IF;

    OPEN object_version_cur(customer_party_rec.party_id,'INSTRUMENT_ID') ;
     FETCH object_version_cur INTO object_version_rec;
     CLOSE object_version_cur;

    HZ_PREFERENCE_PUB.Put(
        p_party_id                 => customer_party_rec.party_id
    , p_category                  => 'LAST_USED_PAYMENT_INSTRUMENT'
    , p_preference_code          => 'INSTRUMENT_ID'
    , p_value_number             => p_bank_account_id
    , p_module                   => 'IRECEIVABLES'
    , p_additional_value1        => NULL
    , p_additional_value2        => NULL
    , p_additional_value3        => NULL
    , p_additional_value4        => NULL
    , p_additional_value5        => NULL
    , p_object_version_number    => object_version_rec.object_version_number
    , x_return_status            => p_status
    , x_msg_count                => l_msg_count
    , x_msg_data                 => l_msg_data);

     IF ( p_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                   write_error_messages(l_msg_data, l_msg_count);
                   ROLLBACK TO STORE_INST;
                   RETURN;
            END IF;
     --If payment process goes through, the transaction will be committed irrespective of
     --the result of this procedure. If the record is stored successfully in hz party preference, commit
     COMMIT;


     END store_last_used_ba;

/*========================================================================
 | PUBLIC function is_bank_account_duplicate
 |
 | DESCRIPTION
 |      Checks whether given bank account number already exists
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_bank_account_number IN  VARCHAR2
 |      p_routing_number      IN  VARCHAR2
 |      p_account_holder_name IN  VARCHAR2
 |
 | RETURNS
 |      Return Value: 0 if given bank account number does not exist.
 |                    1 if given bank account number already exists.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-Aug-2001           J Rautiainen      Created
 |
 | 15-Apr-2002           AMMISHRA          Bug:2210677 , Passed an extra
 |                                         parameter p_account_holder_name
 *=======================================================================*/
FUNCTION is_bank_account_duplicate(p_bank_account_number IN  VARCHAR2,
                        p_routing_number      IN  VARCHAR2 DEFAULT NULL,
                        p_account_holder_name IN VARCHAR2) RETURN NUMBER IS

  CURSOR cc_cur(p_instrument_id iby_creditcard.instrid%TYPE)  is
         SELECT  count(1) ca_exists
	 FROM    IBY_FNDCPT_PAYER_ASSGN_INSTR_V IBY
	 WHERE   IBY.instrument_id = p_instrument_id
	 AND     IBY.CARD_HOLDER_NAME <> p_account_holder_name;

  CURSOR ba_cur IS
    SELECT count(1) ba_exists
    FROM   iby_ext_bank_accounts_v ba
    WHERE  ba.branch_number       = p_routing_number
    AND    ba.bank_account_number = p_bank_account_number
    AND    ROWNUM = 1
    AND    ba.bank_account_name <> p_account_holder_name;

   ba_rec ba_cur%ROWTYPE;
   cc_rec cc_cur%ROWTYPE;

   l_create_credit_card		IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
   l_result_rec			IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   l_procedure_name		VARCHAR2(30);
   l_return_status		VARCHAR2(2);
   l_msg_count			NUMBER;
   l_msg_data			VARCHAR2(2000);
BEGIN
  l_procedure_name := '.is_bank_account_duplicate';

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,' Begin +');
    end if;

  IF p_routing_number IS NULL THEN

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,' Calling..  IBY_FNDCPT_SETUP_PUB.Card_Exists ');
    end if;

	   IBY_FNDCPT_SETUP_PUB.Card_Exists(
		 p_api_version      => 1.0,
		 p_init_msg_list    => FND_API.G_FALSE,
		 x_return_status    => l_return_status,
		 x_msg_count        => l_msg_count,
		 x_msg_data         => l_msg_data,
		 p_owner_id         => null,
		 p_card_number      => p_bank_account_number,
		 x_card_instrument  => l_create_credit_card,
		 x_response         => l_result_rec);

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_return_status :: ' || l_return_status);
    end if;

	  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	      -- no card exists
		   return 0;
	  ELSE
	       OPEN  cc_cur(l_create_credit_card.card_id);
	       FETCH cc_cur into cc_rec;
	       CLOSE cc_cur;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_create_credit_card.card_id :: ' || l_create_credit_card.card_id);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'cc_rec.ca_exists :: ' || cc_rec.ca_exists);
    end if;

	       if cc_rec.ca_exists = 0 then
		       return 0;
	       else
		       return 1;
	       end if;

	  END IF;

  ELSE

    open ba_cur;
    fetch ba_cur into ba_rec;
    close ba_cur;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'ba_rec.ba_exists :: ' || ba_rec.ba_exists);
    end if;

    if ba_rec.ba_exists = 0 then
       return 0;
    else
       return 1;
    end if;

  END IF;

EXCEPTION

WHEN OTHERS THEN
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Account Number: '||p_bank_account_number);
      write_debug_and_log('- Holder Name: '||p_account_holder_name);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);

      FND_MSG_PUB.ADD;

END is_bank_account_duplicate;

/*========================================================================
 | PUBLIC function is_bank_account_duplicate
 |
 | DESCRIPTION
 |      Checks whether given bank account number already exists
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_bank_account_number IN  VARCHAR2
 |
 | RETURNS
 |      Return Value: 0 if given bank account number does not exist.
 |                    1 if given bank account number already exists.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-Aug-2001           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_credit_card_duplicate(p_bank_account_number IN  VARCHAR2,
				  p_account_holder_name IN  VARCHAR2) RETURN NUMBER IS
BEGIN
  return  is_bank_account_duplicate(p_bank_account_number => p_bank_account_number,
                                    p_routing_number      => NULL,
			            p_account_holder_name => p_account_holder_name);
END is_credit_card_duplicate;

/*========================================================================
 | PUBLIC function get_iby_account_type
 |
 | DESCRIPTION
 |      Maps AP bank account type to a iPayment bank account type. If
 |      AP bank account type is not recognized, CHECKING is used.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_account_type      Account type from the ap table
 |
 | RETURNS
 |      iPayment bank account type
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Feb-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_iby_account_type(p_account_type        IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR account_type_cur IS
    select LOOKUP_CODE
    from FND_LOOKUPS
    where LOOKUP_TYPE = 'IBY_BANKACCT_TYPES'
    and   LOOKUP_CODE = UPPER(p_account_type);

  account_type_rec account_type_cur%ROWTYPE;
BEGIN

  OPEN  account_type_cur;
  FETCH account_type_cur INTO account_type_rec;

  IF account_type_cur%FOUND THEN
    CLOSE account_type_cur;
    RETURN account_type_rec.LOOKUP_CODE;
  ELSE
    CLOSE account_type_cur;
    RETURN 'CHECKING';
  END IF;

END get_iby_account_type;

/*===========================================================================+
 | PROCEDURE write_debug_and_log                                             |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Writes standard messages to standard debugging and to the log          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_message - Message to be writted                       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Feb-2002  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE write_debug_and_log(p_message IN VARCHAR2) IS

BEGIN

 /*------------------------------------------------+
  | Write the message to log and to the standard   |
  | debugging channel                              |
  +------------------------------------------------*/
  IF FND_GLOBAL.CONC_REQUEST_ID is not null THEN

   /*------------------------------------------------+
    | Only write to the log if call was made from    |
    | concurrent program.                            |
    +------------------------------------------------*/
    fnd_file.put_line(FND_FILE.LOG,p_message);

  END IF;

  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug('OIR'|| p_message);
  END IF;
EXCEPTION
  WHEN others THEN
   /*-------------------------------------------------------+
    | Error writing to the log, nothing we can do about it. |
    | Error is not raised since API messages also contain   |
    | non fatal warnings. If a real exception happened it   |
    | is handled on the calling routine.                    |
    +-------------------------------------------------------*/
    NULL;

END write_debug_and_log;

/*===========================================================================+
 | PROCEDURE write_API_output                                                |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Writes API output to the concurrent program log. Messages from the     |
 |    API can contain warnings and errors                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_msg_count  - Number of messages from the API          |
 |                   p_msg_data   - Actual messages from the API             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Feb-2002  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE write_API_output(p_msg_count        IN NUMBER,
                           p_msg_data         IN VARCHAR2) IS

  l_msg_data       VARCHAR2(2000);
BEGIN

    --Bug 3810143 - Ensure that the messages are picked up from the message
    --stack in any case.
    FOR l_count IN 1..p_msg_count LOOP

         l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
         write_debug_and_log(to_char(l_count)||' : '||l_msg_data);

    END LOOP;

EXCEPTION
  WHEN others THEN
   /*-------------------------------------------------------+
    | Error writing to the log, nothing we can do about it. |
    | Error is not raised since API messages also contain   |
    | non fatal warnings. If a real exception happened it   |
    | is handled on the calling routine.                    |
    +-------------------------------------------------------*/
    NULL;

END write_API_output;

/*========================================================================
 | PUBLIC store_last_used_cc
 |
 | DESCRIPTION
 |      Backward compatibility methods introduced for mobile account
 |      management.
 |      ----------------------------------------
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Mar-2002           J Rautiainen      Created
 | 26-Apr-2004           vnb               Added Customer Site as input parameter.
 |
 *=======================================================================*/

PROCEDURE store_last_used_cc(p_customer_id     IN  NUMBER,
                             p_bank_account_id IN  NUMBER,
                             p_status          OUT NOCOPY VARCHAR2) IS

BEGIN
store_last_used_ba(p_customer_id     => p_customer_id,
                   p_bank_account_id => p_bank_account_id,
                   p_instr_type      => 'CC',
                   p_status          => p_status);


END store_last_used_cc;


/*============================================================
 | PUBLIC procedure create_invoice_pay_list
 |
 | DESCRIPTION
 |   Creates a list of transactions to be paid by the customer
 |   based on the list type. List type has the following values:
 |   OPEN_INVOICES
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_customer_id           IN    NUMBER
 |   p_currency_code         IN    VARCHAR2
 |   p_customer_site_use_id  IN    NUMBER DEFAULT NULL
 |   p_payment_schedule_id   IN    NUMBER DEFAULT NULL
 |   p_trx_type              IN    VARCHAR2 DEFAULT NULL
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 13-Jan-2003   krmenon      Created
 | 31-Dec-2004   vnb          Bug 4071551 - Removed redundant code
 | 20-Jan-2005   vnb          Bug 4117211 - Original discount amount column added for ease of resetting payment amounts
 | 08-Jul-2005	 rsinthre     Bug 4437225 - Disputed amount against invoice not displayed during payment
 | 05-Mar-2010   avepati    Bug#9173720 -Able to see same invoice twice in payment details page.
 | 22-Mar-2010   nkanchan     Bug 8293098 - Service change based on credit card types
 | 09-Jun-2010   nkanchan Bug # 9696274- PAGE ERRORS OUT ON NAVIGATING 'PAY BELOW' RELATED CUSTOMER DATA
 +============================================================*/
PROCEDURE create_invoice_pay_list ( p_customer_id           IN NUMBER,
                                    p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                                    p_payment_schedule_id   IN NUMBER DEFAULT NULL,
                                    p_currency_code         IN VARCHAR2,
                                    p_payment_type           IN varchar2 DEFAULT NULL,
                                    p_lookup_code           IN varchar2 DEFAULT NULL) IS

  -- Cursor to fetch all the open invoices
  CURSOR open_invoice_list (p_customer_id NUMBER,
                            p_customer_site_use_id NUMBER,
                            p_payment_schedule_id NUMBER,
                            p_currency_code VARCHAR2) IS
  SELECT ps.CUSTOMER_ID,
           ps.CUSTOMER_SITE_USE_ID,   -- Bug # 3828358
           acct.ACCOUNT_NUMBER,
           ps.CUSTOMER_TRX_ID,
           ps.TRX_NUMBER,
           ps.TRX_DATE,
  	 ps.class,
           ps.DUE_DATE,
  	 ps.PAYMENT_SCHEDULE_ID,
           ps.STATUS,
           trm.name term_desc,
  	 ARPT_SQL_FUNC_UTIL.Get_Number_Of_Due_Dates(ps.term_id) number_of_installments,
  	 ps.terms_sequence_number,
  	 ps.amount_line_items_original line_amount,
  	 ps.tax_original tax_amount,
  	 ps.freight_original freight_amount,
  	 ps.receivables_charges_charged finance_charge,
  	 ps.INVOICE_CURRENCY_CODE,
  	 ps.AMOUNT_DUE_ORIGINAL,
  	 ps.AMOUNT_DUE_REMAINING,
  	 0 payment_amt,
  	 0 service_charge,
  	 0 discount_amount,
  	 TRUNC(SYSDATE) receipt_date,
  	 '' receipt_number,
           ct.PURCHASE_ORDER AS PO_NUMBER,
           NULL AS SO_NUMBER,
           ct.printing_option,

           ct.ATTRIBUTE_CATEGORY,
           ct.ATTRIBUTE1,
           ct.ATTRIBUTE2,
           ct.ATTRIBUTE3,
           ct.ATTRIBUTE4,
           ct.ATTRIBUTE5,
           ct.ATTRIBUTE6,
           ct.ATTRIBUTE7,
           ct.ATTRIBUTE8,
           ct.ATTRIBUTE9,
           ct.ATTRIBUTE10,
           ct.ATTRIBUTE11,
           ct.ATTRIBUTE12,
           ct.ATTRIBUTE13,
           ct.ATTRIBUTE14,
           ct.ATTRIBUTE15,
           ct.INTERFACE_HEADER_CONTEXT,
	   ct.INTERFACE_HEADER_ATTRIBUTE1,
	   ct.INTERFACE_HEADER_ATTRIBUTE2,
	   ct.INTERFACE_HEADER_ATTRIBUTE3,
	   ct.INTERFACE_HEADER_ATTRIBUTE4,
	   ct.INTERFACE_HEADER_ATTRIBUTE5,
	   ct.INTERFACE_HEADER_ATTRIBUTE6,
	   ct.INTERFACE_HEADER_ATTRIBUTE7,
	   ct.INTERFACE_HEADER_ATTRIBUTE8,
	   ct.INTERFACE_HEADER_ATTRIBUTE9,
	   ct.INTERFACE_HEADER_ATTRIBUTE10,
	   ct.INTERFACE_HEADER_ATTRIBUTE11,
	   ct.INTERFACE_HEADER_ATTRIBUTE12,
	   ct.INTERFACE_HEADER_ATTRIBUTE13,
	   ct.INTERFACE_HEADER_ATTRIBUTE14,
	   ct.INTERFACE_HEADER_ATTRIBUTE15,
  	 sysdate LAST_UPDATE_DATE,
  	 0 LAST_UPDATED_BY,
  	 sysdate CREATION_DATE,
  	 0 CREATED_BY,
  	 0 LAST_UPDATE_LOGIN,
  	 0 APPLICATION_AMOUNT,
  	 0 CASH_RECEIPT_ID,
  	 0  ORIGINAL_DISCOUNT_AMT,
           ps.org_id,
  	 ct.PAYING_CUSTOMER_ID,
  	 ct.PAYING_SITE_USE_ID,
( decode( nvl(ps.AMOUNT_DUE_ORIGINAL,0),0,1,(ps.AMOUNT_DUE_ORIGINAL/abs(ps.AMOUNT_DUE_ORIGINAL)) ) *abs(nvl(ps.amount_in_dispute,0)) ) dispute_amt
  FROM AR_PAYMENT_SCHEDULES ps,
       RA_CUSTOMER_TRX ct,
       HZ_CUST_ACCOUNTS acct,
       RA_TERMS trm
  WHERE ps.CLASS IN ('INV', 'DM', 'CB', 'DEP')
  AND ps.customer_trx_id = ct.customer_trx_id
  AND acct.cust_account_id = ps.customer_id
  AND ps.status = 'OP'
  AND ps.term_id = trm.term_id(+)
  AND ( ps.payment_schedule_id = p_payment_schedule_id
  	OR   p_payment_schedule_id IS NULL)

	 AND ps.customer_id = p_customer_id
	 AND ps.customer_site_use_id = nvl(decode(p_customer_site_use_id, -1, null, p_customer_site_use_id), ps.customer_site_use_id)
	 AND ps.invoice_currency_code = p_currency_code;

  l_query_period NUMBER(15);
  l_query_date   DATE;
  l_total_service_charge NUMBER;
  l_discount_amount NUMBER;
  l_rem_amt_rcpt    NUMBER;
  l_rem_amt_inv     NUMBER;
  l_grace_days_flag VARCHAR2(2);

  l_paying_cust_id  NUMBER(15);
  l_pay_for_cust_id NUMBER(15);
  l_pay_for_cust_site_id NUMBER(15);
  l_paying_cust_site_id  NUMBER(15);
  l_dispute_amount	NUMBER := 0;
  l_trx_rec_exists number :=0;

  l_procedure_name  VARCHAR2(50);
  l_debug_info      VARCHAR2(200);

  TYPE t_open_invoice_list_rec
        IS TABLE OF open_invoice_list%ROWTYPE index by binary_integer ;

  l_open_invoice_list_rec  t_open_invoice_list_rec;


BEGIN
  --Assign default values
  l_query_period         := -12;
  l_total_service_charge := 0;
  l_discount_amount      := 0;
  l_rem_amt_rcpt         := 0;
  l_rem_amt_inv          := 0;
  l_procedure_name       := '.create_invoice_pay_list';

  SAVEPOINT create_invoice_pay_list_sp;

  ----------------------------------------------------------------------------------------
  l_debug_info := 'Clear the transaction list for the active customer, site, currency';
  -----------------------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  --Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
  --DELETE FROM AR_IREC_PAYMENT_LIST_GT
  --WHERE CUSTOMER_ID        = p_customer_id
  --AND CUSTOMER_SITE_USE_ID = nvl(p_customer_site_use_id, CUSTOMER_SITE_USE_ID)
  --AND CURRENCY_CODE        = p_currency_code;
-- commented the delete sql as part of  bug 9173720

--Added for bug # 9696274
  if(p_payment_schedule_id is not null) then
    DELETE FROM AR_IREC_PAYMENT_LIST_GT
    WHERE  PAYMENT_SCHEDULE_ID = p_payment_schedule_id
    AND CURRENCY_CODE        = p_currency_code;
  end if;

  ----------------------------------------------------------------------------------------
  l_debug_info := 'Fetch all the rows into the global temporary table';
  -----------------------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  Open  open_invoice_list(p_customer_id,
                               p_customer_site_use_id,
                               p_payment_schedule_id,
                               p_currency_code );
  FETCH  open_invoice_list BULK COLLECT INTO l_open_invoice_list_rec;
    close open_invoice_list;

    --l_grace_days_flag := is_grace_days_enabled_wrapper();
    l_grace_days_flag := ARI_UTILITIES.is_discount_grace_days_enabled(p_customer_id,p_customer_site_use_id);

  FOR trx IN l_open_invoice_list_rec.first .. l_open_invoice_list_rec.last loop

     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Inserting: '||l_open_invoice_list_rec(trx).trx_number);
     END IF;

     ----------------------------------------------------------------------------------------
     l_debug_info := 'Calculate discount';
     -----------------------------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
     END IF;


     arp_discounts_api.get_discount(p_ps_id	        => l_open_invoice_list_rec(trx).payment_schedule_id,
		                    p_apply_date	=> trunc(sysdate),
                            	    p_in_applied_amount => l_open_invoice_list_rec(trx).amount_due_remaining - l_open_invoice_list_rec(trx).dispute_amt,
		                    p_grace_days_flag   => l_grace_days_flag,
		                    p_out_discount      => l_open_invoice_list_rec(trx).ORIGINAL_DISCOUNT_AMT,
		                    p_out_rem_amt_rcpt 	=> l_rem_amt_rcpt,
		                    p_out_rem_amt_inv 	=> l_rem_amt_inv,
				    p_called_from	=> 'OIR');

     l_open_invoice_list_rec(trx).discount_amount := l_open_invoice_list_rec(trx).ORIGINAL_DISCOUNT_AMT;

    l_open_invoice_list_rec(trx).PAYING_CUSTOMER_ID := l_open_invoice_list_rec(trx).CUSTOMER_ID;
    l_open_invoice_list_rec(trx).PAYING_SITE_USE_ID := l_open_invoice_list_rec(trx).CUSTOMER_SITE_USE_ID;

    --Bug 4479224
	l_open_invoice_list_rec(trx).CUSTOMER_ID := p_customer_id;
	if(p_customer_site_use_id = null) then
		l_open_invoice_list_rec(trx).CUSTOMER_SITE_USE_ID := -1;
	else
		l_open_invoice_list_rec(trx).CUSTOMER_SITE_USE_ID := p_customer_site_use_id;
	end if;



    BEGIN
	        l_open_invoice_list_rec(trx).payment_amt  := ARI_UTILITIES.curr_round_amt(l_open_invoice_list_rec(trx).AMOUNT_DUE_REMAINING
		                                           - l_open_invoice_list_rec(trx).discount_amount - l_open_invoice_list_rec(trx).dispute_amt,
							     l_open_invoice_list_rec(trx).INVOICE_CURRENCY_CODE);

    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;

--Commented for bug # 9696274
-- Added for bug 	9173720
--		BEGIN
--    select 1 into l_trx_rec_exists FROM ar_irec_payment_list_gt where payment_schedule_id = l_open_invoice_list_rec(trx).payment_schedule_id;
--   EXCEPTION
--   WHEN NO_DATA_FOUND THEN
--        l_trx_rec_Exists :=0;
--    END;

--    IF (l_trx_rec_exists = 1) Then
--	l_open_invoice_list_rec.delete(trx);
--    END IF ;
   end loop;

    FORALL trx
    IN l_open_invoice_list_rec.first .. l_open_invoice_list_rec.last
    INSERT INTO AR_IREC_PAYMENT_LIST_GT
      VALUES l_open_invoice_list_rec(trx);

   ----------------------------------------------------------------------------------------
   l_debug_info := 'Compute service charge';
   -----------------------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
      arp_standard.debug(l_debug_info);
   END IF;
   l_total_service_charge := get_service_charge(p_customer_id, p_customer_site_use_id, p_payment_type, p_lookup_code);

   COMMIT;

EXCEPTION
     WHEN OTHERS THEN
         IF (PG_DEBUG = 'Y') THEN
             arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
	     arp_standard.debug('- Customer Id: '||p_customer_id);
	     arp_standard.debug('- Customer Site Use Id: '|| p_customer_site_use_id);
	     arp_standard.debug('- Currency Code: '||p_currency_code);
             arp_standard.debug('- Payment Schedule Id: '||p_payment_schedule_id);
             arp_standard.debug('ERROR =>'|| SQLERRM);
         END IF;

	 ROLLBACK TO create_invoice_pay_list_sp;

         FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
         FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
         FND_MSG_PUB.ADD;
END create_invoice_pay_list;

/*============================================================
  | PUBLIC procedure create_open_credit_pay_list
  |
  | DESCRIPTION
  |   Copy all open credit transactions for the active customer, site and currency from the
  |   AR_PAYMENT_SCHEDULES to the Payment List GT
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_customer_id               IN NUMBER
  |   p_customer_site_use_id      IN NUMBER DEFAULT NULL
  |   p_currency_code             IN VARCHAR2
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 21-JAN-2004   rsinthre     Created
  | 08-Jul-2005	  rsinthre     Bug 4437225 - Disputed amount against invoice not displayed during payment
  +============================================================*/

PROCEDURE create_open_credit_pay_list(p_customer_id           IN NUMBER,
                            p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                            p_currency_code         IN VARCHAR2
                           ) IS
  CURSOR credit_transactions_list (p_customer_id NUMBER,
                            p_customer_site_use_id NUMBER,
                            p_currency_code VARCHAR2) IS
  ( SELECT * FROM
   (SELECT ps.CUSTOMER_ID,
         DECODE(ps.CUSTOMER_SITE_USE_ID,null,-1,ps.CUSTOMER_SITE_USE_ID) as CUSTOMER_SITE_USE_ID,
         acct.ACCOUNT_NUMBER,
         ps.CUSTOMER_TRX_ID,
         ps.TRX_NUMBER,
         ps.TRX_DATE,
         ps.class,
         ps.DUE_DATE,
         ps.PAYMENT_SCHEDULE_ID,
         ps.STATUS,
         trm.name term_desc,
         ARPT_SQL_FUNC_UTIL.Get_Number_Of_Due_Dates(ps.term_id) number_of_installments,
         ps.terms_sequence_number,
         ps.amount_line_items_original line_amount,
         ps.tax_original tax_amount,
         ps.freight_original freight_amount,
         ps.receivables_charges_charged finance_charge,
         ps.INVOICE_CURRENCY_CODE,
         ps.AMOUNT_DUE_ORIGINAL,
         DECODE (ps.class, 'PMT', ar_irec_payments.get_pymt_amnt_due_remaining(ps.cash_receipt_id),ps.AMOUNT_DUE_REMAINING) as AMOUNT_DUE_REMAINING,
	 0 payment_amt,
	 0 service_charge,
	 0 discount_amount,
	 TRUNC(SYSDATE) receipt_date,
	 '' receipt_number,
         ct.PURCHASE_ORDER AS PO_NUMBER,
         NULL AS SO_NUMBER,
         ct.printing_option,
	 ct.INTERFACE_HEADER_CONTEXT,
         ct.INTERFACE_HEADER_ATTRIBUTE1,
         ct.INTERFACE_HEADER_ATTRIBUTE2,
         ct.INTERFACE_HEADER_ATTRIBUTE3,
         ct.INTERFACE_HEADER_ATTRIBUTE4,
         ct.INTERFACE_HEADER_ATTRIBUTE5,
         ct.INTERFACE_HEADER_ATTRIBUTE6,
         ct.INTERFACE_HEADER_ATTRIBUTE7,
         ct.INTERFACE_HEADER_ATTRIBUTE8,
         ct.INTERFACE_HEADER_ATTRIBUTE9,
         ct.INTERFACE_HEADER_ATTRIBUTE10,
         ct.INTERFACE_HEADER_ATTRIBUTE11,
         ct.INTERFACE_HEADER_ATTRIBUTE12,
         ct.INTERFACE_HEADER_ATTRIBUTE13,
         ct.INTERFACE_HEADER_ATTRIBUTE14,
         ct.INTERFACE_HEADER_ATTRIBUTE15,
         ps.ATTRIBUTE_CATEGORY,
         ps.ATTRIBUTE1,
         ps.ATTRIBUTE2,
         ps.ATTRIBUTE3,
         ps.ATTRIBUTE4,
         ps.ATTRIBUTE5,
         ps.ATTRIBUTE6,
         ps.ATTRIBUTE7,
         ps.ATTRIBUTE8,
         ps.ATTRIBUTE9,
         ps.ATTRIBUTE10,
         ps.ATTRIBUTE11,
         ps.ATTRIBUTE12,
         ps.ATTRIBUTE13,
         ps.ATTRIBUTE14,
         ps.ATTRIBUTE15,
	 sysdate LAST_UPDATE_DATE,
	 0 LAST_UPDATED_BY,
	 sysdate CREATION_DATE,
	 0 CREATED_BY,
	 0 LAST_UPDATE_LOGIN,
	 0 APPLICATION_AMOUNT,
	 ps.CASH_RECEIPT_ID,
	 0  ORIGINAL_DISCOUNT_AMT,
         ps.org_id,
	 0 PAYING_CUSTOMER_ID,
	 0 PAYING_SITE_USE_ID,
	 0  dispute_amt
  FROM AR_PAYMENT_SCHEDULES ps,
       RA_CUSTOMER_TRX_ALL ct,
       HZ_CUST_ACCOUNTS acct,
       RA_TERMS trm
  WHERE ps.customer_id = p_customer_id
  AND   ( ps.CLASS = 'CM'
          OR
          ps.CLASS = 'PMT'
        )
  AND   ps.customer_trx_id = ct.customer_trx_id(+)
  AND   nvl(ps.customer_site_use_id,-1) = nvl(p_customer_site_use_id, nvl(ps.customer_site_use_id,-1))
  AND   acct.cust_account_id = ps.customer_id
  AND   ps.status = 'OP'
  AND   ps.invoice_currency_code = p_currency_code
  AND   ps.term_id = trm.term_id(+))
  WHERE AMOUNT_DUE_REMAINING < 0);

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);
   TYPE t_credit_transactions_list_rec
         IS TABLE OF credit_transactions_list%ROWTYPE index by binary_integer ;

   l_credit_transactions_list_rec  t_credit_transactions_list_rec ;

BEGIN
    l_procedure_name           := '.create_open_credit_pay_list';


    ---------------------------------------------------------------------------
    l_debug_info := 'Fetch all open credit transactions into Payment List GT';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    Open  credit_transactions_list(p_customer_id,
                                 p_customer_site_use_id,
                                 p_currency_code );
    FETCH  credit_transactions_list BULK COLLECT INTO l_credit_transactions_list_rec;
      close credit_transactions_list;

    	 FOR trx IN l_credit_transactions_list_rec.first .. l_credit_transactions_list_rec.last loop
    		l_credit_transactions_list_rec(trx).payment_amt  := l_credit_transactions_list_rec(trx).AMOUNT_DUE_REMAINING;
	   end loop;

	 FORALL trx
	   IN l_credit_transactions_list_rec.first .. l_credit_transactions_list_rec.last

	   INSERT INTO AR_IREC_PAYMENT_LIST_GT
	   VALUES l_credit_transactions_list_rec(trx);

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Customer Id: '||p_customer_id);
        arp_standard.debug('- Customer Site Use Id: '||p_customer_site_use_id);
        arp_standard.debug('- Currency Code: '||p_currency_code);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END create_open_credit_pay_list;

/*============================================================
 | PUBLIC procedure cal_discount_and_service_chrg
 |
 | DESCRIPTION
 |   Calculate discount and service charge on the selected
 |   invoices and update the amounts
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |   This procedure acts on the rows inserted in the global
 |   temporary table by the create_invoice_pay_list procedure.
 |   It is session specific.
 |
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 13-Jan-2003   krmenon      Created
 | 26-Apr-2004   vnb          Added Customer and Customer Site as input params.
 | 10-Jun-2004   vnb          Bug # 3458134 - Check if the grace days for discount option is
 |							  enabled while calculating discount
 | 19-Jul-2004   vnb          Bug # 2830823 - Added exception block to handle exceptions
 | 31-Dec-2004   vnb          Bug 4071551 - Removed redundant code
 | 07-Jul-2005		 rsinthre  Bug 4437220 - Payment amount not changed when discount recalculated
 | 22-Mar-2010   nkanchan     Bug 8293098 - Service change based on credit card types
 +============================================================*/
PROCEDURE cal_discount_and_service_chrg (p_customer_id	IN NUMBER,
                                         p_site_use_id  IN NUMBER DEFAULT NULL,
                                         p_receipt_date IN DATE DEFAULT trunc(SYSDATE),
                                         p_payment_type  IN varchar2 DEFAULT NULL,
                                         p_lookup_code  IN varchar2 DEFAULT NULL) IS
  --l_invoice_list        ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE;

  l_total_service_charge  NUMBER;
  l_count                 NUMBER;
  l_payment_amount        NUMBER;
  l_prev_disc_amt         NUMBER;
  l_discount_amount       NUMBER;
  l_amt_due_remaining     NUMBER;
  l_rem_amt_rcpt          NUMBER;
  l_rem_amt_inv           NUMBER;
  l_grace_days_flag          VARCHAR2(2);

  l_procedure_name           VARCHAR2(50);
  l_debug_info               VARCHAR2(200);

  --Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
  --Bug 4062938 - Select only debit transactions
  CURSOR invoice_list IS
    SELECT  payment_schedule_id,
            receipt_date,
            payment_amt as payment_amount,
            amount_due_remaining,
            discount_amount,
            customer_id,
            account_number,
            customer_trx_id,
            currency_code,
            service_charge
    FROM AR_IREC_PAYMENT_LIST_GT
    WHERE customer_id = p_customer_id
    AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
    AND trx_class in ('INV','DEP', 'DM', 'CB')
    FOR UPDATE;

BEGIN
   --Assign default values
   l_total_service_charge     := 0;
   l_discount_amount          := 0;
   l_payment_amount           := 0;
   l_prev_disc_amt            := 0;
   l_amt_due_remaining        := 0;
   l_rem_amt_rcpt             := 0;
   l_rem_amt_inv              := 0;
   l_procedure_name           := '.cal_discount_and_service_chrg';

   SAVEPOINT cal_disc_and_service_charge_sp;

   -- Check if grace days have to be considered for discount.
   --l_grace_days_flag := is_grace_days_enabled_wrapper();
   l_grace_days_flag := ARI_UTILITIES.is_discount_grace_days_enabled(p_customer_id,p_site_use_id);

   -- Create the invoice list table
   FOR invoice_rec in invoice_list
   LOOP
      ---------------------------------------------------------------------------
      l_debug_info := 'Calculate discount';
      ---------------------------------------------------------------------------
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug(l_debug_info);
      END IF;
      l_prev_disc_amt       := invoice_rec.discount_amount;
      l_payment_amount          := invoice_rec.payment_amount;
      l_amt_due_remaining   := invoice_rec.amount_due_remaining;
      arp_discounts_api.get_discount(  p_ps_id	            => invoice_rec.payment_schedule_id,
		                       p_apply_date	    => trunc(p_receipt_date),
                            	       p_in_applied_amount  => invoice_rec.payment_amount,
		                       p_grace_days_flag    => l_grace_days_flag,
		                       p_out_discount       => l_discount_amount,
		                       p_out_rem_amt_rcpt   => l_rem_amt_rcpt,
		                       p_out_rem_amt_inv    => l_rem_amt_inv);

      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug('Trx: '||invoice_rec.payment_schedule_id||
	                         ' Discount: '||l_discount_amount||
	                         ' Rcpt: '||l_rem_amt_rcpt||
		                 ' Inv: '||l_rem_amt_inv);
      END IF;

     	-- Bug 4352272 - Support both positive and negative invoices
	if((abs(l_payment_amount + l_discount_amount) > abs(l_amt_due_remaining)) OR (abs(l_payment_amount + l_prev_disc_amt) = abs(l_amt_due_remaining))) then
		l_payment_amount := l_amt_due_remaining - l_discount_amount;
	end if;



      -----------------------------------------------------------------------------------------
      l_debug_info := 'Update transaction list with discount and receipt date';
      -----------------------------------------------------------------------------------------
      IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug(l_debug_info);
      END IF;
      UPDATE AR_IREC_PAYMENT_LIST_GT
      SET discount_amount = l_discount_amount,
	      receipt_date    = trunc(p_receipt_date),
          payment_amt = l_payment_amount
      WHERE CURRENT OF invoice_list;

   END LOOP;

   -----------------------------------------------------------------------------------------
   l_debug_info := 'Compute service charge';
   -----------------------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
      arp_standard.debug(l_debug_info);
   END IF;
   -- Bug # 3467287 - The service charge calculator API is striped by
   --                 Customer and Customer Site.
   -- Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.is_service_charge_enabled
   l_total_service_charge := get_service_charge(p_customer_id, p_site_use_id, p_payment_type, p_lookup_code);

   --COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    	BEGIN
            write_debug_and_log('Unexpected Exception while calculating discount and service charge');
            write_debug_and_log('- Customer Id: '||p_customer_id);
            write_debug_and_log('- Customer Site Id: '||p_site_use_id);
            write_debug_and_log('- Total Service charge: '||l_total_service_charge);
            write_debug_and_log(SQLERRM);
        END;

	ROLLBACK TO cal_disc_and_service_charge_sp;

	FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
        FND_MSG_PUB.ADD;

END cal_discount_and_service_chrg;

/*============================================================
 | procedure create_payment_instrument
 |
 | DESCRIPTION
 |   Creates a payment instrument with the given details
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 15-Jun-2005   rsinthre     Created
 | 18-Oct-2005	 rsinthre     Bug 4673563 - Error making credit card payment
 | 04-Aug-2009   avepati      Bug 8664350 - R12 UNABLE TO LOAD FEDERAL RESERVE ACH PARTICIPANT DATA
 | 11-Nov-2009  avepati      Bug 8915943 -  BANK DETAILS NOT COMING ON CLICKING SHOW DETAILS FOR BANK
 +============================================================*/
 PROCEDURE create_payment_instrument (  p_customer_id         IN NUMBER,
					p_customer_site_id    IN NUMBER,
					p_account_number      IN VARCHAR2,
					p_payer_party_id      IN NUMBER,
					p_expiration_date     IN DATE,
					p_account_holder_name IN VARCHAR2,
					p_account_type        IN VARCHAR2,
					p_payment_instrument  IN VARCHAR2,
					p_address_country     IN VARCHAR2 default null,
					p_bank_branch_id      IN NUMBER ,
					p_receipt_curr_code   IN VARCHAR2,
					p_bank_id	      IN NUMBER,
					p_card_brand	      IN VARCHAR2,
					p_cc_bill_to_site_id  IN NUMBER,
					p_single_use_flag     IN VARCHAR2,
					p_iban	        IN VARCHAR2,
          p_routing_number      IN VARCHAR2,
					p_status              OUT NOCOPY VARCHAR2,
					x_msg_count           OUT NOCOPY NUMBER,
					x_msg_data            OUT NOCOPY VARCHAR2,
				  p_assignment_id       OUT NOCOPY NUMBER,
				  p_bank_account_id     OUT NOCOPY NUMBER) IS


  l_create_credit_card		IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
  l_ext_bank_act_rec		IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
  l_result_rec			IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  l_location_rec		HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
  l_party_site_rec		HZ_PARTY_SITE_V2PUB.party_site_rec_type;
  l_payerContext_Rec_type	IBY_FNDCPT_COMMON_PUB.PayerContext_Rec_type;
  l_pmtInstrAssignment_Rec_type	IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
  l_pmtInstr_rec_type		IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;

  l_payer_attibute_id		NUMBER(15,0);

  l_instrument_type		VARCHAR2(20);
  l_assignment_id		NUMBER(15,0);
--  l_bank_account_id		NUMBER;
  x_return_status               VARCHAR2(100);
  l_procedure_name		VARCHAR2(30);
  l_debug_info	 	        VARCHAR2(200);
--  l_commit                      VARCHAR2(2);

 -- added for bug 8664350
  CURSOR bank_branch_cur(l_routing_number VARCHAR2) IS
      SELECT decode(country,null, bank_home_country,country) country_code,bank_party_id,branch_party_id
      FROM   ce_bank_branches_V
      WHERE  branch_number = l_routing_number;

  CURSOR bank_branch_name_cur (l_routing_number VARCHAR2) IS
      SELECT decode(bank_name,null,routing_number,bank_name) bank_name,
             decode(bank_name,null,routing_number,bank_name) branch_name
      FROM   ar_bank_directory
      WHERE  routing_number = l_routing_number;

   CURSOR ce_chk_bank_exists_cur(l_bank_name VARCHAR2) IS   -- cursor to check whether the bank exists in ce_bank_Branches_v or not
      SELECT bank_party_id,branch_party_id, branch_number
      FROM   ce_bank_branches_V
      WHERE  upper(bank_name) = upper(l_bank_name);

    l_api_version               NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(30) DEFAULT FND_API.G_TRUE;
    l_commit                    VARCHAR2(30) DEFAULT FND_API.G_FALSE;
    l_bank_account_id           iby_ext_bank_accounts_v.bank_account_id%TYPE;
    l_start_date                iby_ext_bank_accounts_v.start_date%TYPE;
    l_end_date                  iby_ext_bank_accounts_v.end_date%TYPE;
    l_bank_acct_response        iby_fndcpt_common_pub.result_rec_type;
    l_bank_response             IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    l_branch_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    l_ext_bank_rec            	IBY_EXT_BANKACCT_PUB.extbank_rec_type;
    l_ext_branch_rec            IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type;
    l_bank_party_id             ce_bank_branches_v.bank_party_id%TYPE;
    l_branch_party_id           ce_bank_branches_v.branch_party_id%TYPE;
    l_address_country           ce_bank_branches_v.country% TYPE default 'US';
    l_bank_name                 ar_bank_directory.bank_name%type;
    l_branch_name               ar_bank_directory.bank_name%type;

    l_bank_id                   ce_bank_branches_v.bank_party_id%TYPE;
    l_branch_id                 ce_bank_branches_v.branch_party_id%TYPE;

    bank_branch_rec             bank_branch_cur%ROWTYPE;
    bank_branch_name_rec        bank_branch_name_cur%ROWTYPE;
    ce_chk_bank_exists_rec      ce_chk_bank_exists_cur%ROWTYPE;

BEGIN

  l_procedure_name  := '.create_payment_instrument';
  l_commit :=  FND_API.G_FALSE;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'p_bank_id :: ' ||p_bank_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'p_bank_branch_id :: ' ||p_bank_branch_id);
      end if;

  IF (p_payment_instrument = 'BANK_ACCOUNT') THEN

    l_bank_id  := p_bank_id;
    l_branch_id := p_bank_branch_id;

    OPEN bank_branch_cur(p_routing_number);
    FETCH bank_branch_cur INTO bank_branch_rec;

    IF (bank_branch_cur%FOUND) then
      CLOSE bank_branch_cur;
      l_bank_party_id   := bank_branch_rec.bank_party_id;
      l_branch_party_id := bank_branch_rec.branch_party_id;
      l_address_country := bank_branch_rec.country_code;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank and Branch exist for this Routing Number'||p_routing_number);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank Id :: ' ||l_bank_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Branch Id :: ' ||l_branch_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_address_country :: ' ||l_address_country);
      end if;

    l_bank_id  := l_bank_party_id;  --bug 8915943
    l_branch_id := l_branch_party_id;

    ELSE
     CLOSE bank_branch_cur;
    END IF;

--Fetching bank and branch names

    OPEN bank_branch_name_cur(p_routing_number);
    FETCH bank_branch_name_cur INTO bank_branch_name_rec;

    IF (bank_branch_name_cur%FOUND) then
      CLOSE bank_branch_name_cur;
      l_bank_name   := bank_branch_name_rec.bank_name;
      l_branch_name := bank_branch_name_rec.branch_name;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Fetcheing Bank Name and Branch name for this routing number :: '||p_routing_number);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank Name :: ' ||l_bank_name);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Branch Name :: ' ||l_branch_name);

      end if;
    ELSE
     CLOSE bank_branch_name_cur;
    END IF;

-- Check wether bank already exists in CE . If bank aleady exists create a branch with this routing number for that bank
    OPEN ce_chk_bank_exists_cur(l_bank_name);
    FETCH ce_chk_bank_exists_cur INTO ce_chk_bank_exists_rec;

    IF (ce_chk_bank_exists_cur%FOUND and l_bank_name is not null) then
      CLOSE ce_chk_bank_exists_cur;
      l_bank_party_id   := ce_chk_bank_exists_rec.bank_party_id;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, 'This Bank ' || l_bank_name || ' for the routing number '|| p_routing_number ||'already exists in CE_BANK_BRANCHES_V');
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank Id :: ' ||l_bank_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Branch Id :: ' ||l_branch_party_id);
      end if;

    ELSE
     CLOSE ce_chk_bank_exists_cur;
    END IF;

  IF ( l_bank_party_id is not NULL and  l_branch_party_id is NULL)   THEN

    l_ext_branch_rec.branch_party_id := NULL;
    l_ext_branch_rec.bank_party_id   := l_bank_party_id;
    l_ext_branch_rec.branch_name     := p_routing_number;
    l_ext_branch_rec.branch_number   := p_routing_number;
    l_ext_branch_rec.branch_type     := 'ABA';
    l_ext_branch_rec.bch_object_version_number :='1';
    l_ext_branch_rec.typ_object_version_number :='1';

		if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Calling iby_ext_bankacct_pub.create_ext_bank_branch .....');
    end if;

    iby_ext_bankacct_pub.create_ext_bank_branch(
      -- IN parameters
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_ext_bank_branch_rec => l_ext_branch_rec,
      -- OUT parameters
      x_branch_id           => l_branch_party_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_response            => l_branch_response);

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'End iby_ext_bankacct_pub.create_ext_bank_branch');
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'branch party id :: '||l_branch_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'branch x_return_status ::' || x_return_status);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'branch x_msg_data ::' || x_msg_data);
     end if;

    IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
					l_bank_id   := l_bank_party_id;
          l_branch_id := l_branch_party_id;
    end if;

     /*---------------------------------------------------------------+
      | If bank and branch could not be found, create new bank,branch |
      +---------------------------------------------------------------*/

	elsif   ( l_bank_party_id is  NULL and  l_branch_party_id is NULL)   THEN

    l_ext_bank_rec.bank_id          := NULL;
    l_ext_bank_rec.bank_name        := l_bank_name;
    l_ext_bank_rec.bank_number      := p_routing_number;
    l_ext_bank_rec.institution_type := 'BANK';
    l_ext_bank_rec.country_code     := 'US';  --Create banks are used from Federal Sites.. which has details about US banks only.
    l_ext_bank_rec.object_version_number := '1';

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Calling iby_ext_bankacct_pub.create_ext_bank .....');
    end if;

      iby_ext_bankacct_pub.create_ext_bank(
      -- IN parameters
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_ext_bank_rec        => l_ext_bank_rec,
      -- OUT parameters
      x_bank_id             => l_bank_party_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_response            => l_bank_response );

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'end  iby_ext_bankacct_pub.create_ext_bank');
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'bank party Id ::' || l_bank_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'bank x_return_status ::' || x_return_status);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'bank x_msg_data ::' || x_msg_data);
    end if;

    IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
          l_bank_id   := l_bank_party_id;
    end if;

    l_ext_branch_rec.branch_party_id := NULL;
    l_ext_branch_rec.bank_party_id   := l_bank_party_id;
    l_ext_branch_rec.branch_name     := l_branch_name;
    l_ext_branch_rec.branch_number   := p_routing_number;
    l_ext_branch_rec.branch_type     := 'ABA';
    l_ext_branch_rec.bch_object_version_number :='1';
    l_ext_branch_rec.typ_object_version_number :='1';

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Calling iby_ext_bankacct_pub.create_ext_bank_branch .....');
    end if;

    iby_ext_bankacct_pub.create_ext_bank_branch(
      -- IN parameters
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_ext_bank_branch_rec => l_ext_branch_rec,
      -- OUT parameters
      x_branch_id           => l_branch_party_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_response            => l_branch_response);

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'End iby_ext_bankacct_pub.create_ext_bank_branch');
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'branch party id :: '||l_branch_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'branch x_return_status ::' || x_return_status);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'branch x_msg_data ::' || x_msg_data);
     end if;

    IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
          l_branch_id := l_branch_party_id;
    end if;
end if;

  --------------------------------------------------------------------------------------------------------
  l_debug_info := 'Call IBY create external bank acct - create_ext_bank_acct - to Create a new bank account';
  ---------------------------------------------------------------------------------------------------------

      l_ext_bank_act_rec.acct_owner_party_id		:=  p_payer_party_id;
      if(p_address_country IS NULL OR p_address_country = '') then
            l_ext_bank_act_rec.country_code		:= l_address_country;
      else  l_ext_bank_act_rec.country_code		:= p_address_country;
      end if;
      l_ext_bank_act_rec.bank_account_name		:= p_account_holder_name;
      l_ext_bank_act_rec.bank_account_num		:= p_account_number;
      l_ext_bank_act_rec.bank_id           		 := l_bank_id;
      l_ext_bank_act_rec.branch_id          		:= l_branch_id;
      l_ext_bank_act_rec.currency		:= p_receipt_curr_code;
      l_ext_bank_act_rec.multi_currency_allowed_flag	:= 'Y';
      l_ext_bank_act_rec.acct_type		:= p_account_type;
      l_ext_bank_act_rec.iban			:= p_iban;

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'calling IBY_EXT_BANKACCT_PUB.create_ext_bank_acct ..');
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.bank_id :: '||l_ext_bank_act_rec.bank_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.branch_id ::' || l_ext_bank_act_rec.branch_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.country_code ::' || l_ext_bank_act_rec.country_code);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.acct_owner_party_id :: '||l_ext_bank_act_rec.acct_owner_party_id);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.bank_account_num ::' || l_ext_bank_act_rec.bank_account_num);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.currency ::' || l_ext_bank_act_rec.currency);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.bank_account_name ::' || l_ext_bank_act_rec.bank_account_name);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.iban	 ::' || l_ext_bank_act_rec.iban	);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_ext_bank_act_rec.acct_type ::' || l_ext_bank_act_rec.acct_type);
    end if;

    IBY_EXT_BANKACCT_PUB.create_ext_bank_acct(
      p_api_version                => 1.0,
      p_init_msg_list            	 => FND_API.G_FALSE,
      p_ext_bank_acct_rec          => l_ext_bank_act_rec,
      x_acct_id		=> l_bank_account_id,
      x_return_status            	 => x_return_status,
      x_msg_count                	 => x_msg_count,
      x_msg_data                 	 => x_msg_data,
      x_response                   => l_result_rec);

      write_debug_and_log('l_bank_account_id :'||l_bank_account_id);
      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            x_msg_data := l_result_rec.result_code;
            p_status := FND_API.G_RET_STS_ERROR;
            write_error_messages(x_msg_data, x_msg_count);
            RETURN;
     END IF;

   ELSE
-----------------------------------------------------------------------------------------
  l_debug_info := 'Call IBY create card - Create_Card - to Create a new CC';
-----------------------------------------------------------------------------------------

	  l_create_credit_card.Card_Id                   := NULL;
	  l_create_credit_card.Owner_Id                  := p_payer_party_id;
	  l_create_credit_card.Card_Holder_Name          := p_account_holder_name;
	  if p_cc_bill_to_site_id > 0 then
		  l_create_credit_card.Billing_Address_Id        := p_cc_bill_to_site_id;
		  l_create_credit_card.Billing_Postal_Code       := NULL;
		  l_create_credit_card.Billing_Address_Territory := NULL;
	  else
		  l_create_credit_card.Billing_Address_Id        := NULL;
		  l_create_credit_card.Billing_Postal_Code       := 94065;
		  l_create_credit_card.Billing_Address_Territory := 'US';
	  end if;
	  l_create_credit_card.Card_Number               := p_account_number;
	  l_create_credit_card.Expiration_Date           := p_expiration_date;
	  l_create_credit_card.Instrument_Type           := 'CREDITCARD';
	  l_create_credit_card.PurchaseCard_SubType      := NULL;
	  l_create_credit_card.Card_Issuer               := p_card_brand;
	  l_create_credit_card.Single_Use_Flag           := p_single_use_flag;
	  l_create_credit_card.Info_Only_Flag            := 'N';

	IBY_FNDCPT_SETUP_PUB.create_card(
	 p_api_version      => 1.0,
	 p_init_msg_list    => FND_API.G_FALSE,
	 p_commit           => l_commit,
	 x_return_status    => x_return_status,
	 x_msg_count        => x_msg_count,
	 x_msg_data         => x_msg_data,
	 p_card_instrument  => l_create_credit_card,
	 x_card_id          => l_bank_account_id,
	 x_response         => l_result_rec);

        write_debug_and_log('l_card_id :'||l_bank_account_id);
	IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	          p_status := FND_API.G_RET_STS_ERROR;
                  x_msg_data := l_result_rec.result_code;
	          write_error_messages(x_msg_data, x_msg_count);
	          RETURN;
	END IF;
  END IF;

	--Now assign the instrument to the payer.
	-----------------------------------------------------------------------------------------
	  l_debug_info := 'Call IBY Instrumnet Assignment - To assign instrument';
	-----------------------------------------------------------------------------------------
	if(p_payment_instrument = 'BANK_ACCOUNT') then
		l_instrument_type := 'BANKACCOUNT';
	else
		l_instrument_type := 'CREDITCARD';
	end if;

	l_payerContext_Rec_type.Payment_Function	:= 'CUSTOMER_PAYMENT';
	l_payerContext_Rec_type.Party_Id		:= p_payer_party_id;
	l_payerContext_Rec_type.Cust_Account_Id		:= p_customer_id;
	if(p_customer_site_id is not null) then
		l_payerContext_Rec_type.Org_Type		:= 'OPERATING_UNIT';
		l_payerContext_Rec_type.Org_Id			:= mo_global.get_current_org_id;
		l_payerContext_Rec_type.Account_Site_id		:= p_customer_site_id;
	end if;


	l_pmtInstr_rec_type.Instrument_type := l_instrument_type;
	l_pmtInstr_rec_type.Instrument_Id   := l_bank_account_id;

	l_pmtInstrAssignment_Rec_type.Assignment_Id	:= NULL;
	l_pmtInstrAssignment_Rec_type.Instrument	:= l_pmtInstr_rec_type;
	l_pmtInstrAssignment_Rec_type.Priority		:= 1;
	l_pmtInstrAssignment_Rec_type.Start_Date	:= sysdate;
	l_pmtInstrAssignment_Rec_type.End_Date		:= NULL;


	IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(
		    p_api_version      => 1.0,
		    p_init_msg_list    => FND_API.G_FALSE,
		    p_commit           => FND_API.G_TRUE,
		    x_return_status    => x_return_status,
		    x_msg_count        => x_msg_count,
		    x_msg_data         => x_msg_data,
		    p_payer            => l_payerContext_Rec_type,
		    p_assignment_attribs => l_pmtInstrAssignment_Rec_type,
		    x_assign_id        => l_assignment_id,
		    x_response         => l_result_rec
	);

	IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		  p_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := l_result_rec.result_code;
		  write_error_messages(x_msg_data, x_msg_count);
		  RETURN;
	END IF;
	p_assignment_id := l_assignment_id;
	p_bank_account_id := l_bank_account_id;
	p_status := x_return_status;

	write_debug_and_log('instrument_assignment_id :'||p_assignment_id );

	   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Payment Instrument - Return status - '||x_return_status);
		fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Payment Instrument - Message Count - '||x_msg_count);
		fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Payment Instrument - Message Data - '||x_msg_data);
		fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Payment Instrument - Credit Card Number - '||p_account_number);
	  end if;

	  IF (PG_DEBUG = 'Y') THEN
	    arp_standard.debug(l_debug_info);
	  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_status := FND_API.G_RET_STS_ERROR;
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Card Number: '||p_account_number);
      write_debug_and_log('- CC Billing Addrress Site Id: '||p_cc_bill_to_site_id);
      write_debug_and_log('- Singe Use Flag: '||p_single_use_flag);
      write_debug_and_log('- Return Status: '||p_status);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;
END create_payment_instrument;

/*============================================================
 | procedure create_cc_bill_to_site
 |
 | DESCRIPTION
 |   Creates/Updates Credit card bill to location with the given details
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 17-Aug-2005   rsinthre     Created
 +============================================================*/
PROCEDURE create_cc_bill_to_site(
		p_init_msg_list		IN   VARCHAR2  := FND_API.G_FALSE,
		p_commit		IN   VARCHAR2  := FND_API.G_TRUE,
		p_cc_location_rec	IN   HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
		p_payer_party_id	IN   NUMBER,
		x_cc_bill_to_site_id	IN OUT  NOCOPY NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_count		OUT NOCOPY NUMBER,
		x_msg_data		OUT NOCOPY VARCHAR2) IS

l_location_id			NUMBER(15,0);
l_location_rec			HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_party_site_rec		HZ_PARTY_SITE_V2PUB.party_site_rec_type;
l_party_site_number		VARCHAR2(30);
l_object_version_number		NUMBER(15,0);
CURSOR location_id_cur IS
	select hps.location_id, hl.object_version_number from hz_party_sites hps, hz_locations hl where party_site_id = x_cc_bill_to_site_id
	and hps.location_id = hl.location_id;
  location_id_rec	location_id_cur%ROWTYPE;

l_procedure_name		VARCHAR2(30);
l_debug_info	 	        VARCHAR2(200);

BEGIN
	l_procedure_name  := '.create_cc_bill_to_site';
	-----------------------------------------------------------------------------------------
	 l_debug_info := 'Call TCA create location - create_location - to create location for new CC';
	-----------------------------------------------------------------------------------------

		hz_location_v2pub.create_location(
		    p_init_msg_list              => p_init_msg_list,
		    p_location_rec               => p_cc_location_rec,
		    x_location_id                => l_location_id,
		    x_return_status              => x_return_status,
		    x_msg_count                  => x_msg_count,
		    x_msg_data                   => x_msg_data);

		    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		      x_return_status := FND_API.G_RET_STS_ERROR;
		      write_error_messages(x_msg_data, x_msg_count);
		      RETURN;
		    END IF;

                write_debug_and_log('cc_billing_location_id :'||l_location_id);

		l_party_site_rec.party_id := p_payer_party_id;
		l_party_site_rec.location_id := l_location_id;
		l_party_site_rec.identifying_address_flag := 'N';
		l_party_site_rec.created_by_module := 'ARI';

		hz_party_site_v2pub.create_party_site (
		p_init_msg_list         => p_init_msg_list,
		p_party_site_rec        => l_party_site_rec,
		x_party_site_id         => x_cc_bill_to_site_id,
		x_party_site_number     => l_party_site_number,
		x_return_status         => x_return_status,
		x_msg_count             => x_msg_count,
		x_msg_data              => x_msg_data
		);

		write_debug_and_log('cc_billing_site_id :'||x_cc_bill_to_site_id);

		IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	          x_return_status := FND_API.G_RET_STS_ERROR;
	          write_error_messages(x_msg_data, x_msg_count);
	          RETURN;
		END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Return Status: '||x_return_status);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END create_cc_bill_to_site;

/*============================================================
 | PUBLIC procedure create_receipt
 |
 | DESCRIPTION
 |   Creates a cash receipt fpr the given customer
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 13-Jan-2003   krmenon      Created
 | 17-Nov-2004   vnb          Bug 4000279 - Modified to return error message, if any
 +============================================================*/
 PROCEDURE create_receipt (p_payment_amount		IN NUMBER,
                           p_customer_id		IN NUMBER,
                           p_site_use_id		IN NUMBER,
                           p_bank_account_id		IN NUMBER,
                           p_receipt_date		IN DATE DEFAULT trunc(SYSDATE),
                           p_receipt_method_id		IN NUMBER,
                           p_receipt_currency_code	IN VARCHAR2,
                           p_receipt_exchange_rate	IN NUMBER,
                           p_receipt_exchange_rate_type IN VARCHAR2,
                           p_receipt_exchange_rate_date IN DATE,
                           p_trxn_extn_id		IN NUMBER,
                           p_cash_receipt_id		OUT NOCOPY NUMBER,
                           p_status			OUT NOCOPY VARCHAR2,
                           x_msg_count			OUT NOCOPY NUMBER,
                           x_msg_data			OUT NOCOPY VARCHAR2) IS

  l_receipt_method_id       AR_CASH_RECEIPTS_ALL.RECEIPT_METHOD_ID%TYPE;
  l_receipt_creation_status VARCHAR2(80);
  l_cash_receipt_id         AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE;
  x_return_status           VARCHAR2(100);

  l_procedure_name           VARCHAR2(30);
  l_debug_info	 	     VARCHAR2(200);
  l_instr_assign_id	     NUMBER;

BEGIN

  l_procedure_name  := '.create_receipt';

  fnd_log_repository.init;

  -----------------------------------------------------------------------------------------
  l_debug_info := 'Call public AR receipts API - create_cash - to create receipt for payment';
  -----------------------------------------------------------------------------------------
  write_debug_and_log('p_payment_amount:'||p_payment_amount);
  write_debug_and_log('p_receipt_method_id:'||p_receipt_method_id);
  write_debug_and_log('p_trxn_extn_id:'||p_trxn_extn_id);
  write_debug_and_log('p_customer_id:'||p_customer_id);
  write_debug_and_log('p_site_use_id:'||p_site_use_id);
  write_debug_and_log('p_receipt_currency_code:'||p_receipt_currency_code);
  -------------------------------------------------------------------------------------------

  AR_RECEIPT_API_PUB.create_cash(
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_TRUE,
    	    p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_amount                => p_payment_amount,
            p_receipt_method_id     => p_receipt_method_id,
            p_customer_id           => p_customer_id,
            p_customer_site_use_id  => p_site_use_id,
            p_default_site_use	=> 'N',
            p_payment_trxn_extension_id     => p_trxn_extn_id,
            p_currency_code         => p_receipt_currency_code,
            p_exchange_rate         => p_receipt_exchange_rate,
            p_exchange_rate_type    => p_receipt_exchange_rate_type,
            p_exchange_rate_date    => p_receipt_exchange_rate_date,
            p_receipt_date          => trunc(p_receipt_date),
            p_gl_date               => trunc(p_receipt_date),
            p_cr_id                 => l_cash_receipt_id,
            p_called_from           => 'IREC');

  p_cash_receipt_id := l_cash_receipt_id;
  p_status := x_return_status;
  write_debug_and_log('p_receipt_currency_code:'||l_cash_receipt_id);

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Cash - Rerturn status - '||x_return_status);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Cash - Message Count - '||x_msg_count);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Cash - Message Data - '||x_msg_data);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Create Cash - CR Id - '||l_cash_receipt_id);
  end if;

  arp_standard.debug('X_RETURN_STATUS=>'||X_RETURN_STATUS);
  arp_standard.debug('X_MSG_COUNT=>'||to_char(X_MSG_COUNT));

EXCEPTION
    WHEN OTHERS THEN
      p_status := FND_API.G_RET_STS_ERROR;

      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Customer Id: '||p_customer_id);
      write_debug_and_log('- Customer Site Id: '||p_site_use_id);
      write_debug_and_log('- Cash Receipt Id: '||p_cash_receipt_id);
      write_debug_and_log('- Bank Account Id: '||p_bank_account_id);
      write_debug_and_log('- Return Status: '||p_status);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END create_receipt;

/*=============================================================
 | HISTORY
 |  17-Nov-2004   vnb          Bug 4000279 - Modified to return error message, if any
 |
 | PARAMETERS
 |
 |   p_customer_id          IN    Customer Id
 |   p_site_use_id          IN    Customer Site Id
 |   p_cash_receipt_id      IN    Cash Receipt Id
 |   p_return_status       OUT    Success/Error status
 |   p_apply_err_count     OUT    Number of unsuccessful applications
 |
 +=============================================================*/
PROCEDURE apply_cash ( p_customer_id		    IN NUMBER,
                       p_site_use_id            IN NUMBER DEFAULT NULL,
                       p_cash_receipt_id        IN NUMBER,
                       p_return_status         OUT NOCOPY VARCHAR2,
                       p_apply_err_count       OUT NOCOPY NUMBER,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2
                     ) IS

--Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
CURSOR credit_trx_list IS
  SELECT *
  FROM ar_irec_payment_list_gt
  WHERE customer_id = p_customer_id
  AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
  AND ( trx_class = 'CM'
          OR
        trx_class = 'PMT'
	  );

CURSOR debit_trx_list IS
  SELECT *
  FROM ar_irec_payment_list_gt
  WHERE customer_id = p_customer_id
  AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
  AND ( trx_class = 'INV' OR
         trx_class = 'DM' OR
         trx_class = 'GUAR' OR
         trx_class = 'CB' OR
         trx_class = 'DEP'
	   )
  ORDER BY amount_due_remaining ASC;

  x_return_status           VARCHAR2(100);

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(255);
  l_apply_err_count         NUMBER;

  l_application_ref_num        ar_receivable_applications.application_ref_num%TYPE;
  l_receivable_application_id  ar_receivable_applications.receivable_application_id%TYPE;
  l_applied_rec_app_id         ar_receivable_applications.receivable_application_id%TYPE;
  l_acctd_amount_applied_from  ar_receivable_applications.acctd_amount_applied_from%TYPE;
  l_acctd_amount_applied_to    ar_receivable_applications.acctd_amount_applied_to%TYPE;

  l_procedure_name VARCHAR2(30);
  l_debug_info	   VARCHAR2(200);

 credit_trx_list_count NUMBER;
 debit_trx_list_count NUMBER;
 total_trx_count NUMBER;

BEGIN

  --Assign default values
  l_msg_count       := 0;
  l_apply_err_count := 0;
  l_procedure_name  := '.apply_cash';

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'In apply_cash: p_customer_id='||p_customer_id ||','
	              || 'p_site_use_id=' || p_site_use_id || ','
	              || 'p_cash_receipt_id=' || p_cash_receipt_id);
    end if;

    --Pring in the debug log : Total No of rows in ar_irec_payment_list_gt

  SELECT COUNT(*)
  INTO 	 total_trx_count
  FROM 	 ar_irec_payment_list_gt;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Total no of rows in ar_irec_payment_list_gt='||total_trx_count);
  end if;

--Pring in the debug log : No of rows that will be picked by the cursor credit_trx_list

  SELECT  COUNT(*)
  INTO    credit_trx_list_count
  FROM    ar_irec_payment_list_gt
  WHERE   customer_id = p_customer_id
  AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
  AND ( trx_class = 'CM'  OR trx_class = 'PMT' );

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'credit_trx_list_count: '||credit_trx_list_count);
  end if;

--Pring in the debug log : No of rows that will be picked by the cursor debit_trx_list

  SELECT  count(*)
  INTO    debit_trx_list_count
  FROM    ar_irec_payment_list_gt
  WHERE   customer_id = p_customer_id
  AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
  AND ( trx_class = 'INV' OR
         trx_class = 'DM' OR
         trx_class = 'GUAR' OR
         trx_class = 'CB' OR
         trx_class = 'DEP'
	   );

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'debit_trx_list_count: ' || debit_trx_list_count);
  end if;

  --
  -- Establish a save point
  --
  SAVEPOINT ARI_Apply_Cash_Receipt_PVT;

  ----------------------------------------------------------------------------------
  l_debug_info := 'Step 1: Apply credits against the receipt (if any)';
  ----------------------------------------------------------------------------------

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
    end if;

  FOR trx in credit_trx_list
  LOOP

  	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, 'trx.trx_class=' || trx.trx_class);
        end if;

        IF (trx.trx_class = 'CM') THEN
        -- The transaction is a credit memo

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Calling AR_RECEIPT_API_PUB.apply for CM:'
                  ||'trx.customer_trx_id=' || trx.customer_trx_id || ','
                  ||'trx.terms_sequence_number=' || trx.terms_sequence_number || ','
                  ||'trx.payment_schedule_id=' || trx.payment_schedule_id || ','
                  ||'trx.payment_amt=' || trx.payment_amt || ','
                  ||'trx.discount_amount=' || trx.discount_amount);
        end if;

            AR_RECEIPT_API_PUB.apply(
                            p_api_version           => 1.0,
                            p_init_msg_list         => FND_API.G_TRUE,
                            p_commit                => FND_API.G_FALSE,
                            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data,
                            p_cash_receipt_id       => p_cash_receipt_id,
                            p_customer_trx_id       => trx.customer_trx_id,
                            p_installment           => trx.terms_sequence_number,
                            p_applied_payment_schedule_id => trx.payment_schedule_id,
                            p_amount_applied        => trx.payment_amt,
                            p_discount              => trx.discount_amount,
			    p_apply_date            => trunc(trx.receipt_date),
                            p_called_from           => 'IREC'
                            );

	   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Execution of AR_RECEIPT_API_PUB.apply is over');
	   end if;

        ELSE
        -- The transaction must be a payment

          if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Calling AR_RECEIPT_API_PUB.apply_open_receipt for PMT:'
              || 'trx.cash_receipt_id='  || trx.cash_receipt_id ||','
              || 'trx.payment_amt=' || trx.payment_amt || ','
              || 'l_application_ref_num=' || l_application_ref_num || ','
              || 'l_receivable_application_id=' || l_receivable_application_id || ','
              || 'l_applied_rec_app_id=' || l_applied_rec_app_id || ','
              || 'l_acctd_amount_applied_from=' || l_acctd_amount_applied_from || ','
              || 'l_acctd_amount_applied_to=' || l_acctd_amount_applied_to);
	    end if;

            AR_RECEIPT_API_PUB.apply_open_receipt
                            (p_api_version                 => 1.0,
                             p_init_msg_list               => FND_API.G_TRUE,
                             p_commit                      => FND_API.G_FALSE,
                             x_return_status               => x_return_status,
                             x_msg_count                   => x_msg_count,
                             x_msg_data                    => x_msg_data,
                             p_cash_receipt_id             => p_cash_receipt_id,
                             p_open_cash_receipt_id        => trx.cash_receipt_id,
                             p_amount_applied              => trx.payment_amt,
                             p_called_from                 => 'IREC',
                             x_application_ref_num         => l_application_ref_num,
                             x_receivable_application_id   => l_receivable_application_id,
                             x_applied_rec_app_id          => l_applied_rec_app_id,
                             x_acctd_amount_applied_from   => l_acctd_amount_applied_from,
                             x_acctd_amount_applied_to     => l_acctd_amount_applied_to
                             );

	   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Execution of AR_RECEIPT_API_PUB.apply_open_receipt is over');
	   end if;

        END IF;

          if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'x_return_status=' || x_return_status);
	   end if;

        -- Check for errors and increment the count for
        -- errored applcations
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_apply_err_count := l_apply_err_count + 1;
            p_apply_err_count := l_apply_err_count;
            p_return_status   := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO ARI_Apply_Cash_Receipt_PVT;
            RETURN;
        END IF;

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Applied receipt '||trx.trx_number||', Status: '||x_return_status);
        end if;

        write_debug_and_log('X_RETURN_STATUS=>'||X_RETURN_STATUS);
        write_debug_and_log('X_MSG_COUNT=>'||to_char(X_MSG_COUNT));

  END LOOP;
  ----------------------------------------------------------------------------------
  l_debug_info := 'Step 2: Apply debits against the receipt';
  ----------------------------------------------------------------------------------

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
  end if;

  FOR trx in debit_trx_list
  LOOP

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, 'Calling AR_RECEIPT_API_PUB.apply for debit trx: '
	       || 'p_cash_receipt_id=' || p_cash_receipt_id || ','
	       || 'trx.customer_trx_id=' || trx.customer_trx_id || ','
	       || 'trx.payment_schedule_id=' || trx.payment_schedule_id || ','
	       || 'trx.payment_amt=' || trx.payment_amt || ','
	       || 'trx.service_charge='|| trx.service_charge || ','
	       || 'trx.discount_amount=' || trx.discount_amount || ','
	       || 'p_apply_date=' || To_Char(trunc(trx.receipt_date)) );
      end if;

    --
    -- Call the application API
    --
    AR_RECEIPT_API_PUB.apply(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_cash_receipt_id       => p_cash_receipt_id,
        p_customer_trx_id       => trx.customer_trx_id,
        p_applied_payment_schedule_id => trx.payment_schedule_id,
        p_amount_applied        => trx.payment_amt + nvl(trx.service_charge,0),
        p_discount              => trx.discount_amount,
        p_apply_date            => trunc(trx.receipt_date),
        p_called_from           => 'IREC'
        );

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Execution of AR_RECEIPT_API_PUB.apply is over. Return Status=' || x_return_status);
    end if;

    -- Check for errors and increment the count for
    -- errored applcations
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_apply_err_count := l_apply_err_count + 1;
      p_apply_err_count := l_apply_err_count;
      p_return_status   := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO ARI_Apply_Cash_Receipt_PVT;
      RETURN;
    END IF;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Applied Cash to '||trx.trx_number||' Status: '||x_return_status);
    end if;

    write_debug_and_log('X_RETURN_STATUS=>'||X_RETURN_STATUS);
    write_debug_and_log('X_MSG_COUNT=>'||to_char(X_MSG_COUNT));

  END LOOP;

  p_apply_err_count := l_apply_err_count;
  -- There are no errored applications; set the
  -- return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Exiting apply_cash with return status: '||p_return_status);
  end if;

EXCEPTION
    WHEN OTHERS THEN
    	BEGIN
	    p_return_status := FND_API.G_RET_STS_ERROR;

            write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
            write_debug_and_log('- Customer Id: '||p_customer_id);
            write_debug_and_log('- Customer Site Id: '||p_site_use_id);
            write_debug_and_log('- Cash Receipt Id: '||p_cash_receipt_id);
            write_debug_and_log('- Return Status: '||p_return_status);
            write_debug_and_log(SQLERRM);

            FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
            FND_MSG_PUB.ADD;
        END;

END apply_cash;


/*=====================================================================
 | FUNCTION get_service_charge
 |
 | DESCRIPTION
 |   This function will calculate the service charge for the multiple
 |   invoices that have been selected for payment and return the
 |   total service charge that is to be applied.
 |
 | HISTORY
 |   26-APR-2004     vnb      Bug # 3467287 - Added Customer and Customer Site
 |							  as input parameters.
 |   19-JUL-2004     vnb      Bug # 2830823 - Added exception block to handle exceptions
 |   21-SEP-2004     vnb      Bug # 3886652 - Added customer site use id to ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE
 | 22-Mar-2010   nkanchan     Bug 8293098 - Service change based on credit card types
 |
 +=====================================================================*/
 FUNCTION get_service_charge (  p_customer_id		    IN NUMBER,
                                p_site_use_id          IN NUMBER DEFAULT NULL,
                                p_payment_type       IN varchar2 DEFAULT NULL,
                                p_lookup_code       IN varchar2 DEFAULT NULL)
                             RETURN NUMBER IS

 l_invoice_list             ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE;
 l_total_service_charge     NUMBER;
 l_count                    NUMBER;
 l_currency_code            AR_IREC_PAYMENT_LIST_GT.currency_code%TYPE;
 l_service_charge           NUMBER;

 l_procedure_name           VARCHAR2(30);
 l_debug_info	 	    VARCHAR2(200);

 --Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
 --Bug # 3886652 - Added customer site use id to ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE
 CURSOR invoice_list IS
   SELECT  payment_schedule_id,
           payment_amt as payment_amount,
           customer_id,
           customer_site_use_id,
           account_number,
           customer_trx_id,
           currency_code,
           service_charge
   FROM AR_IREC_PAYMENT_LIST_GT
   WHERE customer_id = p_customer_id
   AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
   AND trx_class IN ('INV','DM','CB','DEP');

 BEGIN
  --Assign default values
  l_total_service_charge := 0;
  l_procedure_name       :=  '.get_service_charge';

  SAVEPOINT service_charge_sp;

   ----------------------------------------------------------------------------------------
   l_debug_info := 'Check if service charge is enabled; else return zero';
   -----------------------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
   END IF;
   IF NOT (ARI_UTILITIES.is_service_charge_enabled(p_customer_id, p_site_use_id)) THEN
      RETURN l_total_service_charge;
   END IF;

   ----------------------------------------------------------------------------------------
   l_debug_info := 'Create the invoice list table';
   -----------------------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
   END IF;

   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('In getServiceCharge begin for Loop..');
   END IF;

   FOR invoice_rec in invoice_list
   LOOP

     --Bug 4071551 - Changed the indexing field to Payment Schedule Id from Customer Trx Id to keep uniqueness
     l_count := invoice_rec.payment_schedule_id;

     IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('Index: '||l_count);
     END IF;

     l_invoice_list(l_count).payment_schedule_id := invoice_rec.payment_schedule_id;
     l_invoice_list(l_count).payment_amount      := invoice_rec.payment_amount;
     l_invoice_list(l_count).customer_id         := invoice_rec.customer_id;
     --Bug # 3886652 - Added customer site use id to ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE
     l_invoice_list(l_count).customer_site_use_id:= invoice_rec.customer_site_use_id;
     l_invoice_list(l_count).account_number      := invoice_rec.account_number;
     l_invoice_list(l_count).customer_trx_id     := invoice_rec.customer_trx_id;
     l_invoice_list(l_count).currency_code       := invoice_rec.currency_code;
     l_invoice_list(l_count).service_charge      := invoice_rec.service_charge;

     l_currency_code := invoice_rec.currency_code;

   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('invoice_rec.payment_schedule_id: '||invoice_rec.payment_schedule_id);
       arp_standard.debug('invoice_rec.payment_amount: '||invoice_rec.payment_amount);
       arp_standard.debug('invoice_rec.customer_id: '||invoice_rec.customer_id);
       arp_standard.debug('invoice_rec.customer_site_use_id: '||invoice_rec.customer_site_use_id);
       arp_standard.debug('invoice_rec.account_number: '||invoice_rec.account_number);
       arp_standard.debug('invoice_rec.customer_trx_id '||invoice_rec.customer_trx_id);
       arp_standard.debug('invoice_rec.currency_code: '||invoice_rec.currency_code);
       arp_standard.debug('invoice_rec.service_charge: '||invoice_rec.service_charge);

   END IF;


   END LOOP;

   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('End first Loop. Total records: '||l_invoice_list.COUNT);
   END IF;

   ----------------------------------------------------------------------------------------
   l_debug_info := 'Call the service charge package to compute';
   -----------------------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
   END IF;
   ARI_SERVICE_CHARGE_PKG.compute_service_charge(l_invoice_list, p_payment_type, p_lookup_code);

   l_count := l_invoice_list.FIRST;

   WHILE l_count IS NOT NULL
   LOOP
     l_service_charge := ARI_UTILITIES.curr_round_amt(l_invoice_list(l_count).service_charge, l_currency_code);

     IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('Index: '|| l_count||' PaymentScheduleId: '||l_invoice_list(l_count).payment_schedule_id ||
                          'Service Charge: '||l_invoice_list(l_count).service_charge);
     END IF;

     ----------------------------------------------------------------------------------------
     l_debug_info := 'Update service charge in the Payment GT';
     -----------------------------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
         arp_standard.debug(l_debug_info);
     END IF;
     UPDATE ar_irec_payment_list_gt
     SET    service_charge = l_service_charge
     WHERE  payment_schedule_id = l_invoice_list(l_count).payment_schedule_id;

     l_total_service_charge := l_total_service_charge + l_service_charge;

     -- Error handling required
     IF SQL%ROWCOUNT < 1 THEN
	IF (PG_DEBUG = 'Y') THEN
	   arp_standard.debug('Error - Cannot update '||l_count);
        END IF;
     END IF;

     l_count := l_invoice_list.NEXT(l_count);

   END LOOP;

   COMMIT;

   RETURN l_total_service_charge;

 EXCEPTION
    WHEN OTHERS THEN
    	BEGIN
            write_debug_and_log('Unexpected Exception while computing service charge');
            write_debug_and_log('- Customer Id: '||p_customer_id);
            write_debug_and_log('- Customer Site Id: '||p_site_use_id);
            write_debug_and_log('- Total Service charge: '||l_total_service_charge);
            write_debug_and_log(SQLERRM);
        END;

	ROLLBACK TO service_charge_sp;

	FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
        FND_MSG_PUB.ADD;

 END get_service_charge;

/*=====================================================================
 | PROCEDURE apply_service_charge
 |
 | DESCRIPTION
 |   This function will calculate the service charge for the multiple
 |   invoices that have been selected for payment and return the
 |   total service charge that is to be applied.
 |
 | HISTORY
 |  26-APR-2004  vnb         Bug # 3467287 - Added Customer and Customer Site
 |                           as input parameters.
 |  19-JUL-2004  vnb         Bug # 2830823 - Added exception block to handle exceptions
 |  21-SEP-2004  vnb         Bug # 3886652 - Added customer site use id to ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE
 |
 +=====================================================================*/
 PROCEDURE apply_service_charge ( p_customer_id		    IN NUMBER,
                                  p_site_use_id         IN NUMBER DEFAULT NULL,
                                  x_return_status OUT NOCOPY VARCHAR2) IS

 l_invoice_list             ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE;
 l_total_service_charge     NUMBER;
 l_count                    NUMBER;
 l_return_status            VARCHAR2(2);
 l_procedure_name           VARCHAR2(50);
 l_debug_info	 	    VARCHAR2(200);

 --Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
 --Bug # 3886652 - Added customer site use id to ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE
 CURSOR invoice_list IS
   SELECT  payment_schedule_id,
           payment_amt as payment_amount,
           customer_id,
           customer_site_use_id,
           account_number,
           customer_trx_id,
           currency_code,
           service_charge
   FROM AR_IREC_PAYMENT_LIST_GT
   WHERE customer_id = p_customer_id
    AND customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id), customer_site_use_id)
   AND ( trx_class = 'INV' OR
         trx_class = 'DM' OR
         trx_class = 'GUAR' OR
         trx_class = 'CB' OR
         trx_class = 'DEP'
	   );

 BEGIN
   --Assign default values
   l_total_service_charge := 0;
   l_procedure_name := '.apply_service_charge';

   fnd_log_repository.init;
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'+');
   end if;

   l_count := 1;

   -- Create the invoice list table
   ----------------------------------------------------------------------------------
   l_debug_info := 'Create the invoice list table';
   ----------------------------------------------------------------------------------

  IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('In Apply_Service_Charge begin for Loop..');
   END IF;

   FOR invoice_rec in invoice_list
   LOOP

     --l_count := invoice_rec.customer_trx_id;
     --l_invoice_list.EXTEND;
     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Index: '||l_count);
     end if;
     l_invoice_list(l_count).payment_schedule_id := invoice_rec.payment_schedule_id;
     l_invoice_list(l_count).payment_amount := invoice_rec.payment_amount;
     l_invoice_list(l_count).customer_id := invoice_rec.customer_id;
     --Bug # 3886652 - Added customer site use id to ARI_SERVICE_CHARGE_PKG.INVOICE_LIST_TABTYPE
     l_invoice_list(l_count).customer_site_use_id := invoice_rec.customer_site_use_id;
     l_invoice_list(l_count).account_number := invoice_rec.account_number;
     l_invoice_list(l_count).customer_trx_id := invoice_rec.customer_trx_id;
     l_invoice_list(l_count).currency_code := invoice_rec.currency_code;
     l_invoice_list(l_count).service_charge := invoice_rec.service_charge;


   IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug('invoice_rec.payment_schedule_id: '||invoice_rec.payment_schedule_id);
       arp_standard.debug('invoice_rec.payment_amount: '||invoice_rec.payment_amount);
       arp_standard.debug('invoice_rec.customer_id: '||invoice_rec.customer_id);
       arp_standard.debug('invoice_rec.customer_site_use_id: '||invoice_rec.customer_site_use_id);
       arp_standard.debug('invoice_rec.account_number: '||invoice_rec.account_number);
       arp_standard.debug('invoice_rec.customer_trx_id '||invoice_rec.customer_trx_id);
       arp_standard.debug('invoice_rec.currency_code: '||invoice_rec.currency_code);
       arp_standard.debug('invoice_rec.service_charge: '||invoice_rec.service_charge);

   END IF;

     l_count := l_count + 1;
   END LOOP;

   -- Call the service charge compute package
   ----------------------------------------------------------------------------------
   l_debug_info := 'Apply service charge';
   ----------------------------------------------------------------------------------
   l_return_status := ARI_SERVICE_CHARGE_PKG.apply_charge(l_invoice_list);

   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
     -- bug 3672530 - Ensure graceful error handling
     x_return_status := FND_API.G_RET_STS_ERROR;
     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'ERROR: Loop count is: '||l_count);
     end if;
     APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'-');
   end if;

 EXCEPTION
    WHEN OTHERS THEN
    	BEGIN
	    x_return_status := FND_API.G_RET_STS_ERROR;

            write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
            write_debug_and_log('- Customer Id: '||p_customer_id);
            write_debug_and_log('- Customer Site Id: '||p_site_use_id);
            write_debug_and_log('- Total Service charge: '||l_total_service_charge);
            write_debug_and_log('- Return Status: '||l_return_status);
            write_debug_and_log(SQLERRM);

            FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
            FND_MSG_PUB.ADD;
        END;

END apply_service_charge;


 /*==============================================================
 | PROCEDURE  pay_multiple_invoices
 |
 | DESCRIPTION Used to make paymnets from iRec UI
 |
 | PARAMETERS  Lots
 |
 | KNOWN ISSUES
 |
 | NOTES
 | p_cc_bill_to_site_id value is sent as 0 when OIR_VERIFY_CREDIT_CARD_DETAILS profile is NONE or SECURITY_CODE for both New  Credit Cards
 | p_cc_bill_to_site_id value is sent as -1 when OIR_VERIFY_CREDIT_CARD_DETAILS is either BOTH or ADDRESS and for New Credit Card  Accounts
 | p_cc_bill_to_site_id value is sent as CC bill site id when OIR_VERIFY_CREDIT_CARD_DETAILS profile is either BOTH or ADDRESS for Saved Credit Cards
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 13-Jan-2003   krmenon      Created
 | 21-OCT-2004   vnb          Bug 3944029 - Modified pay_multiple_invoices to pass
 |							  correct site_use_id to other APIs
 | 03-NOV-2004   vnb          Bug 3335944 - One Time Credit Card Verification
 | 18-Oct-2005	 rsinthre     Bug 4673563 - Error making credit card payment
 +==============================================================*/

 PROCEDURE pay_multiple_invoices(p_payment_amount      IN NUMBER,
                                p_discount_amount     IN NUMBER,
                                p_customer_id         IN NUMBER,
                                p_site_use_id         IN NUMBER,
                                p_account_number      IN VARCHAR2,
                                p_expiration_date     IN DATE,
                                p_account_holder_name IN VARCHAR2,
                                p_account_type        IN VARCHAR2,
                                p_payment_instrument  IN VARCHAR2,
                                p_address_line1       IN VARCHAR2 default null,
                                p_address_line2       IN VARCHAR2 default null,
                                p_address_line3       IN VARCHAR2 default null,
                                p_address_city        IN VARCHAR2 default null,
                                p_address_county      IN VARCHAR2 default null,
                                p_address_state       IN VARCHAR2 default null,
                                p_address_country     IN VARCHAR2 default null,
                                p_address_postalcode  IN VARCHAR2 default null,
                                p_cvv2                IN NUMBER,
                                p_bank_branch_id      IN NUMBER,
                                p_receipt_date        IN DATE DEFAULT trunc(SYSDATE),
                                p_new_account_flag    IN VARCHAR2 DEFAULT 'FALSE',
					  p_receipt_site_id     IN NUMBER,
				p_bank_id	      IN NUMBER,
				p_card_brand	      IN VARCHAR2,
				p_cc_bill_to_site_id  IN NUMBER,
				p_single_use_flag     IN VARCHAR2 default 'N',
				p_iban	        IN VARCHAR2,
				p_routing_number      IN VARCHAR2,
				p_instr_assign_id     IN NUMBER default 0,
				p_bank_account_id     IN OUT NOCOPY NUMBER,
                                p_cash_receipt_id     OUT NOCOPY NUMBER,
                                p_status              OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2
                                ) IS
  -- =================================
  -- DECLARE ALL LOCAL VARIABLES HERE
  -- =================================
  l_receipt_currency_code       AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE;
  l_receipt_exchange_rate       AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE%TYPE;
  l_receipt_exchange_rate_type  AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE_TYPE%TYPE;
  l_receipt_exchange_rate_date  DATE;

  l_invoice_exchange_rate       AR_PAYMENT_SCHEDULES_ALL.EXCHANGE_RATE%TYPE;
  l_receipt_method_id           AR_CASH_RECEIPTS_ALL.RECEIPT_METHOD_ID%TYPE;
  l_remit_bank_account_id       AR_CASH_RECEIPTS_ALL.REMIT_BANK_ACCT_USE_ID%TYPE;
  l_receipt_creation_status     VARCHAR2(80);
  l_site_use_id                 NUMBER(15);
  l_bank_account_id 	        NUMBER;
  l_bank_account_uses_id        NUMBER;
  l_cvv2                        iby_fndcpt_tx_extensions.instrument_security_code%TYPE;

  l_invoice_trx_number          AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE;
  l_cr_id                       AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE;
  x_return_status               VARCHAR2(100);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(4000);

  l_call_payment_processor      VARCHAR2(1);
  l_response_error_code         VARCHAR2(80);
  l_bank_branch_id	        CE_BANK_ACCOUNTS.BANK_BRANCH_ID%TYPE;
  l_apply_err_count             NUMBER;
  p_payment_schedule_id         NUMBER;

  l_create_credit_card		IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
  l_result_rec_type		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  l_procedure_name VARCHAR2(30);

  l_debug_info	 	        VARCHAR2(200);

    l_payer_rec			IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
    l_trxn_rec			IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
    l_payee_rec         IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
    l_result_rec		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    l_payment_channel_code	IBY_FNDCPT_PMT_CHNNLS_B.PAYMENT_CHANNEL_CODE%TYPE;

    l_cc_location_rec		HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_cc_bill_to_site_id	NUMBER;

    l_extn_id number;
    l_payer_party_id  NUMBER;

   l_payment_server_order_num VARCHAR2(80);
       l_instr_assign_id number;

    l_cvv_use           VARCHAR2(100);
    l_billing_addr_use  VARCHAR2(100);
  CURSOR party_id_cur IS
    SELECT PARTY_ID FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = p_customer_id;

    party_id_rec		party_id_cur%ROWTYPE;

    p_site_use_id_srvc_chrg NUMBER;
    l_home_country  			varchar2(10);

BEGIN
  --Assign default values

  l_receipt_currency_code  := 'USD';
  l_call_payment_processor := FND_API.G_TRUE;
  l_apply_err_count        := 0;
  x_msg_count              := 0;
  x_msg_data               := '';
  l_procedure_name         := '.pay_multiple_invoices';


  fnd_log_repository.init;

   --------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  --------------------------------------------------------------------
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,
                 'Begin+');
	  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,
                 'p_payment_amount ' ||p_payment_amount ||
                 'p_discount_amount ' ||p_discount_amount ||
                 'p_customer_id ' || p_customer_id ||
                 'p_site_use_id ' ||p_site_use_id ||
                 'p_account_number ' ||p_account_number ||
                 'p_expiration_date ' ||p_expiration_date ||
                 'p_account_holder_name ' ||p_account_holder_name ||
                 'p_account_type ' || p_account_type ||
                 'p_payment_instrument ' || p_payment_instrument ||
                 'p_bank_branch_id ' ||p_bank_branch_id ||
                 'p_new_account_flag ' ||p_new_account_flag ||
                 'p_receipt_date ' ||p_receipt_date ||
                 'p_receipt_site_id '||p_receipt_site_id ||
                 'p_bank_account_id ' ||p_bank_account_id );
  end if;

  -- IF Customer Site Use Id is -1 then it is to be set as null
  IF ( p_site_use_id = -1 ) THEN
    l_site_use_id := NULL;
  ELSE
    l_site_use_id := p_site_use_id;
  END IF;

-- Added for bug 9683510
 IF(p_site_use_id is NULL AND (p_receipt_site_id IS NOT NULL OR  p_receipt_site_id <> -1)) THEN
	l_site_use_id := p_receipt_site_id;
 END IF;

  IF p_cvv2 = 0 AND p_payment_instrument = 'BANK_ACCOUNT' THEN
   l_cvv2 := NULL;
  else
   l_cvv2 := p_cvv2;
  END IF;


  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,
                 'Calling get_payment_information');
  end if;


  ---------------------------------------------------------------------------
  l_debug_info := 'Get the Payment Schedule Id if there is only one invoice';
  ---------------------------------------------------------------------------
  BEGIN
    select payment_schedule_id into p_payment_schedule_id
    from AR_IREC_PAYMENT_LIST_GT
    where customer_id = p_customer_id
    and customer_site_use_id = nvl(l_site_use_id, customer_site_use_id);
    EXCEPTION
      when others then
        IF (PG_DEBUG = 'Y') THEN
          arp_standard.debug('There may be multiple invoices for payment');
        END IF;
  END;

  ---------------------------------------------------------------------------
  l_debug_info := 'Call get_payment_information';
  ---------------------------------------------------------------------------

  get_payment_information(
          p_customer_id             => p_customer_id,
          p_site_use_id             => l_site_use_id,
          p_payment_schedule_id     => p_payment_schedule_id,
          p_payment_instrument      => p_payment_instrument,
          p_trx_date                => trunc(p_receipt_date),
          p_currency_code           => l_receipt_currency_code,
          p_exchange_rate           => l_invoice_exchange_rate,
          p_receipt_method_id       => l_receipt_method_id,
          p_remit_bank_account_id   => l_remit_bank_account_id,
          p_receipt_creation_status => l_receipt_creation_status,
          p_trx_number              => l_invoice_trx_number,
	  p_payment_channel_code    => l_payment_channel_code);

  --DEBUG
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_rct_curr => ' || l_receipt_currency_code);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_rct_method_id => ' ||l_receipt_method_id );
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_remit_bank_account_id => ' || l_Remit_bank_account_id);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_receipt_creation_status => ' || l_receipt_creation_status );
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_site_use_id => ' || l_site_use_id );
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_receipt_currency_code => ' || l_receipt_currency_code);
  end if;

 IF p_payment_instrument = 'CREDIT_CARD' THEN
	  get_payment_channel_attribs
	  (
		  p_channel_code 	   => 'CREDIT_CARD',
		  x_return_status    => x_return_status,
		  x_cvv_use 	       => l_cvv_use,
		  x_billing_addr_use => l_billing_addr_use,
		  x_msg_count 	     => x_msg_count,
		  x_msg_data 	       => x_msg_data
	  );
	    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

		  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			  fnd_log.string(fnd_log.LEVEL_STATEMENT,
				  G_PKG_NAME||l_procedure_name,
				  'ERROR IN GETTING IBY PAYMENT CHANNEL ATTRIBUTES');
		  end if;

		  x_return_status := FND_API.G_RET_STS_ERROR;
		  write_error_messages(x_msg_data, x_msg_count);
		  RETURN;
    	   END IF;

END IF;

  -- If the payment instrument is a bank account then
  -- set the bank branch id
  IF (p_payment_instrument = 'BANK_ACCOUNT') THEN
      l_bank_branch_id := p_bank_branch_id;
  ELSE
      l_bank_branch_id := null;
  END IF;

  --KRMENON DEBUG
IF (l_receipt_currency_code IS NULL OR '' = l_receipt_currency_code) THEN
    --Bug2925392: Get Currency from AR_IREC_PAYMENT_LIST_GT. All records will have same currency.
    --Bug # 3467287 - The Global Temp table must be striped by Customer and Customer Site.
    ---------------------------------------------------------------------------
    l_debug_info := 'If the currency code is not set yet, get the currency code';
    ---------------------------------------------------------------------------
    BEGIN
      select currency_code into l_receipt_currency_code
      from AR_IREC_PAYMENT_LIST_GT
      where customer_id = p_customer_id
      and customer_site_use_id = nvl(l_site_use_id, customer_site_use_id);
      --group by currency_code;
      EXCEPTION
        when others then
          IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug('Error getting currency code');
          END IF;
    END;
  END IF;

  SAVEPOINT ARI_Create_Cash_PVT;

	OPEN party_id_cur;
	FETCH party_id_cur INTO party_id_rec;
	IF(party_id_cur%FOUND) THEN
		l_payer_party_id := party_id_rec.party_id;
	END IF;
	CLOSE party_id_cur;

	l_cc_bill_to_site_id			:= p_cc_bill_to_site_id;
	l_cc_location_rec.country		:= p_address_country;
	l_cc_location_rec.address1		:= p_address_line1;
	l_cc_location_rec.address2		:= p_address_line2;
	l_cc_location_rec.address3		:= p_address_line3;
	l_cc_location_rec.city			:= p_address_city;
	l_cc_location_rec.postal_code		:= p_address_postalcode;
	l_cc_location_rec.state			:= p_address_state;
	l_cc_location_rec.county		:= p_address_county;
	l_cc_location_rec.created_by_module	:= 'ARI';

	IF(p_payment_instrument = 'CREDIT_CARD') and l_cc_bill_to_site_id = -1 THEN
      IF(l_billing_addr_use = 'REQUIRED') THEN
		create_cc_bill_to_site(
			p_init_msg_list		=> FND_API.G_FALSE,
			p_commit		=> FND_API.G_FALSE,
			p_cc_location_rec	=> l_cc_location_rec,
			p_payer_party_id	=> l_payer_party_id,
			x_cc_bill_to_site_id	=> l_cc_bill_to_site_id,
			x_return_status		=> x_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data);

		 IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

		      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			      fnd_log.string(fnd_log.LEVEL_STATEMENT,
				      G_PKG_NAME||l_procedure_name,
				      'ERROR IN CREATING PAYMENT INSTRUMENT');
		      end if;

		      p_status := FND_API.G_RET_STS_ERROR;
		      ROLLBACK TO ARI_Create_Cash_PVT;
		      write_error_messages(x_msg_data, x_msg_count);
		      RETURN;
		 END IF;
      END IF;
	 END IF;	--p_payment_instrument




  IF ( p_new_account_flag = 'TRUE' ) THEN
  -- Now create a payment instrument
    ---------------------------------------------------------------------------
    l_debug_info := 'Create a payment instrument';
    ---------------------------------------------------------------------------
    create_payment_instrument ( p_customer_id         => p_customer_id,
				p_customer_site_id    => l_site_use_id,
				p_account_number      => p_account_number,
				p_payer_party_id      => l_payer_party_id,
				p_expiration_date     => p_expiration_date,
				p_account_holder_name => p_account_holder_name,
				p_account_type        => p_account_type,
				p_payment_instrument  => p_payment_instrument,
				p_address_country     => p_address_country,
				p_bank_branch_id      => p_bank_branch_id,
				p_receipt_curr_code   => l_receipt_currency_code,
				p_status              => x_return_status,
				x_msg_count           => l_msg_count,
				x_msg_data            => l_msg_data,
				p_bank_id	      => p_bank_id,
				p_card_brand	      => p_card_brand,
				p_cc_bill_to_site_id  => l_cc_bill_to_site_id,
				p_single_use_flag     => p_single_use_flag,
				p_iban	        => p_iban,
				p_routing_number     => p_routing_number,
				p_assignment_id       => l_instr_assign_id,
				p_bank_account_id   => p_bank_account_id) ;


    -- Check if the payment instrument was created successfully
    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      fnd_log.string(fnd_log.LEVEL_STATEMENT,
                      G_PKG_NAME||l_procedure_name,
                      'ERROR IN CREATING PAYMENT INSTRUMENT');
      end if;

      p_status := FND_API.G_RET_STS_ERROR;
      write_error_messages(x_msg_data, x_msg_count);
      ROLLBACK TO ARI_Create_Cash_PVT;
      RETURN;
    ELSE
    	-- When payment instrument is created successfully
    	IF ( ARI_UTILITIES.save_payment_instrument_info(p_customer_id, l_site_use_id) ) THEN
	    -- If iRec set up is not to save CC then, if update of CC fails we should roll back even create.
	    -- So here the commit flag is controlled by that profile
	    commit;
 	END IF;
    END IF;

  ELSE
    l_bank_account_id := p_bank_account_id;
    l_instr_assign_id := p_instr_assign_id;
  END IF;


  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Done with bank Creation .....');
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Expiration date for bank account: ' || p_expiration_date);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank Acct Id: '||l_bank_account_id);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank Acct Uses Id: '||l_bank_account_uses_id);
  end if;

  /*------------------------------------+
   | Standard start of API savepoint    |
   +------------------------------------*/
 IF ( ARI_UTILITIES.save_payment_instrument_info(p_customer_id, p_site_use_id) ) THEN
	  SAVEPOINT ARI_Create_Cash_PVT;
 END IF;
  -----------------------------------------------------------------------------------------
  l_debug_info := 'Call public IBY API - create TRANSACTION EXTENSION';
  -----------------------------------------------------------------------------------------

        l_payer_rec.payment_function:='CUSTOMER_PAYMENT';
        l_payer_rec.Cust_Account_Id:=p_customer_id;
        l_payer_rec.Account_Site_Id:=l_site_use_id;
        l_payer_rec.PARTY_ID := l_payer_party_id;
        if l_site_use_id is not null then
	        l_payer_rec.org_type:= 'OPERATING_UNIT';
	        l_payer_rec.org_id:= mo_global.get_current_org_id;
        else
             l_payer_rec.org_type:= NULL;
	        l_payer_rec.org_id:= NULL;
        end if;
	l_payee_rec.org_type := 'OPERATING_UNIT';
	l_payee_rec.org_id := mo_global.get_current_org_id ;

        select 'ARI_'||ar_payment_server_ord_num_s.nextval
        into l_payment_server_order_num
        from dual;

        l_trxn_rec.Originating_Application_Id:=222;
        l_trxn_rec.Order_Id:=l_payment_server_order_num;
        l_trxn_rec.Instrument_Security_Code :=l_cvv2;
        -- Debug message
        write_debug_and_log('l_payment_channel_code'||l_payment_channel_code);
        write_debug_and_log('l_instr_assign_id'||l_instr_assign_id);
        write_debug_and_log('l_payment_server_order_num'||l_payment_server_order_num);

        IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
                          (
			    p_api_version	=>1.0,
			    p_init_msg_list	=>FND_API.G_TRUE,
			--    p_commit		=> FND_API.G_FALSE, -- bug 9683510
         		    x_return_status	=>x_return_status,
		            x_msg_count		=>l_msg_count,
		            x_msg_data		=> l_msg_data,
			    p_payer		=> l_payer_rec,
			    p_pmt_channel	=> l_payment_channel_code,
			    p_instr_assignment	=>l_instr_assign_id,
			    p_trxn_attribs	=> l_trxn_rec,
			    x_entity_id		=> l_extn_id,
			    x_response		=> l_result_rec);

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		      fnd_log.string(fnd_log.LEVEL_STATEMENT,
			      G_PKG_NAME||l_procedure_name,
			      'ERROR IN CREATING TRANSACTION EXTENSION');
		  fnd_log.string(fnd_log.LEVEL_STATEMENT,
			      G_PKG_NAME||l_procedure_name,l_result_rec.result_code);
	      end if;

	      x_msg_count := x_msg_count + l_msg_count;
	      if (l_msg_data is not null) then
		    x_msg_data  := x_msg_data || l_msg_data || '*';
	      end if;

	      x_msg_data := x_msg_data || '*' || l_result_rec.result_code;
	      p_status := FND_API.G_RET_STS_ERROR;
	      ROLLBACK TO ARI_Create_Cash_PVT;
	      write_error_messages(x_msg_data, x_msg_count);
	      RETURN;
    END IF;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Done with create trxn extn.....');
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_extn_id : ' ||l_extn_id);
  end if;
  write_debug_and_log('l_receipt_currency_code : ' || l_receipt_currency_code);
  write_debug_and_log('l_invoice_exchange_rate : ' || to_char(l_invoice_exchange_rate));
  write_debug_and_log('l_extn_id : ' || l_extn_id);

  ---------------------------------------------------------------------------
  l_debug_info := 'Call get_exchange_rate';
  ---------------------------------------------------------------------------
  get_exchange_rate( p_trx_currency_code      => l_receipt_currency_code,
                     p_trx_exchange_rate      => l_invoice_exchange_rate,
                     p_def_exchange_rate_date => trunc(SYSDATE),
                     p_exchange_rate          => l_receipt_exchange_rate,
                     p_exchange_rate_type     => l_receipt_exchange_rate_type,
                     p_exchange_rate_date     => l_receipt_exchange_rate_date);

if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Done with getexchangerate.....');
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_receipt_currency_code : ' || l_receipt_currency_code);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'l_receipt_exchange_rate : ' || to_char(l_invoice_exchange_rate));
  end if;

  -- for demo purposes only: if fnd function ARIPAYMENTDEMOMODE
  -- is added to the menu of the current responsibility, supress
  -- call to iPayment after the receipt creation.

 /*------------------------------------------------------+
  | For credit cards iPayment is called to authorize and |
  | capture the payment. For bank account transfers      |
  | iPayment is called in receivables remittance process |
  +------------------------------------------------------*/
  IF (fnd_function.test('ARIPAYMENTDEMOMODE')
     OR p_payment_instrument = 'BANK_ACCOUNT') THEN /* J Rautiainen ACH Implementation */
    l_call_payment_processor := FND_API.G_FALSE;
  ELSE
    l_call_payment_processor := FND_API.G_TRUE;
  END IF;

-- commented for bug 9683510
/*  IF (p_receipt_site_id <> -1) THEN
    l_site_use_id := p_receipt_site_id;
  END IF;  */

  -- Now create a cash receipt
  ---------------------------------------------------------------------------
  l_debug_info := 'Create a cash receipt: Call create_receipt';
  ---------------------------------------------------------------------------
  create_receipt (p_payment_amount		=> p_payment_amount,
                  p_customer_id			=> p_customer_id,
                  p_site_use_id			=> l_site_use_id,
                  p_bank_account_id		=> l_bank_account_id,
                  p_receipt_date		=> trunc(p_receipt_date),
                  p_receipt_method_id		=> l_receipt_method_id,
                  p_receipt_currency_code	=> l_receipt_currency_code,
                  p_receipt_exchange_rate	=> l_receipt_exchange_rate,
                  p_receipt_exchange_rate_type	=> l_receipt_exchange_rate_type,
                  p_receipt_exchange_rate_date	=> l_receipt_exchange_rate_date,
                  p_trxn_extn_id		=> l_extn_id,
                  p_cash_receipt_id		=> p_cash_receipt_id,
                  p_status			=> x_return_status,
                  x_msg_count			=> l_msg_count,
                  x_msg_data			=> l_msg_data
                 );

  arp_standard.debug('create receipt -->  ' || x_return_status || 'receipt id --> ' || p_cash_receipt_id);
  arp_standard.debug('X_RETURN_STATUS=>'||X_RETURN_STATUS);

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Done with receipt creation ....');
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Return Status: '||x_return_status);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Cash Receipt Id: '||to_char(p_cash_receipt_id));
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Bank Account Id: '||to_char(p_bank_account_id));
  end if;

  -- Check for error in receipt creation. If it is an error
  -- the rollback and return.
  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS OR p_cash_receipt_id IS NULL ) THEN
    --Bug 3672530 - Error handling
    p_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO ARI_Create_Cash_PVT;
    write_error_messages(x_msg_data, x_msg_count);
    RETURN;
  END IF;

  p_site_use_id_srvc_chrg := l_site_use_id;
-- commented for bug 9683510
/*  IF (p_receipt_site_id <> -1) THEN
    p_site_use_id_srvc_chrg := p_receipt_site_id;
  END IF; */

  -- If service charge has been enabled, adjust the invoice
  -- with the service charge
  -- Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.is_service_charge_enabled
  IF ( ARI_UTILITIES.is_service_charge_enabled(p_customer_id, p_site_use_id_srvc_chrg) ) THEN
    ---------------------------------------------------------------------------------
    l_debug_info := 'Service charge enabled: adjust the invoice with service charge';
    ---------------------------------------------------------------------------------
    apply_service_charge(p_customer_id, null, x_return_status);  -- Bug 9596552
    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --Bug 3672530 - Error handling
      p_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO ARI_Create_Cash_PVT;
      write_error_messages(x_msg_data, x_msg_count);
      RETURN;
    END IF;
  END IF;

   --Bug 8239939 , 6026781: All locations project. Reset the site_use_id to actual value
 --when navigating from All Locations or My All Locations
-- commented for bug 9683510
/*  IF (p_receipt_site_id <> -1) THEN
    l_site_use_id := p_site_use_id;
  END IF; */


  -- If the cash receipt has been created successfully then
  -- apply the receipt to the transactions selected
  ---------------------------------------------------------------------------------
  l_debug_info := 'Apply the receipt to the transactions selected:call apply_cash';
  ---------------------------------------------------------------------------------
  apply_cash( p_customer_id     => p_customer_id,
              p_site_use_id     => l_site_use_id,
              p_cash_receipt_id => p_cash_receipt_id,
              p_return_status   => x_return_status,
              p_apply_err_count => l_apply_err_count,
              x_msg_count       => l_msg_count,
              x_msg_data        => l_msg_data
            );

  -- Check if any of the applications errored out
  -- If so the rollback everything and return
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Apply Cash call ended with Status : '||x_return_status);
  end if;

  IF ( l_apply_err_count > 0 ) THEN
    x_msg_count := x_msg_count + l_msg_count;
    if (l_msg_data is not null) then
	    x_msg_data  := x_msg_data || l_msg_data || '*';
    end if;
    p_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO ARI_Create_Cash_PVT;
    write_error_messages(x_msg_data, x_msg_count);
    RETURN;
  END IF;

  -- Seems like all is fine. So we shall go ahead and
  -- do the final task of capturing the CC payment
  -- only if it is a credit card payment
  IF (p_payment_instrument = 'CREDIT_CARD' AND
      l_call_payment_processor = FND_API.G_TRUE) THEN

      BEGIN
            select pr.home_country into l_home_country
            from ar_cash_receipts_all cr,
            ce_bank_acct_uses bau,
            ce_bank_accounts cba,
            hz_parties bank,
            hz_organization_profiles pr
            where cr.cash_receipt_id = p_cash_receipt_id
            AND    cr.remit_bank_acct_use_id = bau.bank_acct_use_id
            AND    bau.bank_account_id = cba.bank_account_id
            AND    cba.bank_id = bank.party_id
            AND    bank.party_id = pr.party_id;
      EXCEPTION
            when others then
              IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug('Error getting Home Country Code..');
                l_home_country := null;
              END IF;
      END;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Got home country code..'||l_home_country);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Calling process_payment .....');
    end if;

    l_payee_rec.Int_Bank_Country_Code := l_home_country;
    --------------------------------------------------------------------
    l_debug_info := 'Capture Credit Card payment';
    --------------------------------------------------------------------
    process_payment(p_cash_receipt_id     => p_cash_receipt_id,
                    p_payer_rec		  => l_payer_rec,
                    p_payee_rec           => l_payee_rec,
                    p_called_from         => 'IREC',
                    p_response_error_code => l_response_error_code,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data,
                    x_return_status       => x_return_status);

   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Process Payment ended with Status : '||x_return_status);
	fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Response Code: '|| l_response_error_code);
    end if;
    -- If the payment processor call fails, then we need to rollback all the changes
    -- made in the create() and apply() routines also.
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 x_msg_count := x_msg_count + l_msg_count;
	 if (l_msg_data is not null) then
		    x_msg_data  := x_msg_data || l_msg_data || '*';
	 end if;

             --   x_msg_data := x_msg_data || '*' || l_result_rec.result_code;  --  bug 8353477
      --Bug 3672530 - Error handling
      p_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO ARI_Create_Cash_PVT;
      write_error_messages(x_msg_data, x_msg_count);
      RETURN; -- exit back to caller
    END IF;

  END IF; -- END PROCESS_PAYMENT CALL
  -- Now that we have successfully captured the payment
  -- erase the CC info if setup says not to store this
  -- info
  -- Bug 3886652 - Customer and Customer Site added to ARI_CONFIG APIs
  --               to add flexibility in configuration.
  IF NOT ( ARI_UTILITIES.save_payment_instrument_info(p_customer_id, p_site_use_id) ) THEN

    ---------------------------------------------------------------------------------------------------------
    l_debug_info := 'Payment instrument information not to be stored, erase the CC information after payment';
    ---------------------------------------------------------------------------------------------------------
          l_create_credit_card.Card_Id                   := l_bank_account_id;
	  l_create_credit_card.Active_Flag               := 'N';
	  l_create_credit_card.Inactive_Date             := TRUNC(SYSDATE - 1);
          l_create_credit_card.single_use_flag           := 'Y';

	IBY_FNDCPT_SETUP_PUB.Update_Card
            (
            p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_TRUE,
            p_commit           => FND_API.G_FALSE,
            x_return_status    => x_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            p_card_instrument  => l_create_credit_card,
            x_response         => l_result_rec_type
            );

	IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	 p_status := FND_API.G_RET_STS_ERROR;
	 x_msg_count := x_msg_count + l_msg_count;
	 if (l_msg_data is not null) then
		    x_msg_data  := x_msg_data || l_msg_data || '*';
	 end if;
	 x_msg_data := x_msg_data || '*' || l_result_rec.result_code;
	 ROLLBACK TO ARI_Create_Cash_PVT;
	 write_error_messages(x_msg_data, x_msg_count);
	 RETURN;
	END IF;
  ELSE
 	IF ( p_new_account_flag = 'FALSE' AND p_payment_instrument = 'CREDIT_CARD' ) THEN
		l_create_credit_card.Card_Id                   := l_bank_account_id;
		l_create_credit_card.single_use_flag           := 'N';
	        l_create_credit_card.Card_Holder_Name          := p_account_holder_name;

    IF(l_billing_addr_use = 'REQUIRED') THEN
      IF(l_cc_bill_to_site_id <> 0 AND l_cc_bill_to_site_id <> -1) THEN
        l_create_credit_card.Billing_Address_Id        := l_cc_bill_to_site_id;
      END IF;
    END IF;

		IBY_FNDCPT_SETUP_PUB.Update_Card
		(
			p_api_version      => 1.0,
			p_init_msg_list    => FND_API.G_TRUE,
			p_commit           => FND_API.G_FALSE,
			x_return_status    => x_return_status,
			x_msg_count        => l_msg_count,
			x_msg_data         => l_msg_data,
			p_card_instrument  => l_create_credit_card,
			x_response         => l_result_rec_type
		);

	        IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		        p_status := FND_API.G_RET_STS_ERROR;
		        x_msg_count := x_msg_count + l_msg_count;
		        if (l_msg_data is not null) then
			            x_msg_data  := x_msg_data || l_msg_data || '*';
		        end if;
		        x_msg_data := x_msg_data || '*' || l_result_rec.result_code;
		        ROLLBACK TO ARI_Create_Cash_PVT;
		        write_error_messages(x_msg_data, x_msg_count);
		        RETURN;
		END IF;
	END IF;

  END IF;

SAVEPOINT ARI_Create_Cash_PVT;

   IF p_cc_bill_to_site_id > 0 THEN
   ---------------------------------------------------------------------------------------------------------
    l_debug_info := 'CC billing site update required';
    ---------------------------------------------------------------------------------------------------------
	   update_cc_bill_to_site(
			p_cc_location_rec	=> l_cc_location_rec,
			x_cc_bill_to_site_id	=> p_cc_bill_to_site_id ,
			x_return_status		=> x_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data);


	  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		p_status := FND_API.G_RET_STS_ERROR;
		x_msg_count := x_msg_count + l_msg_count;
		if (l_msg_data is not null) then
			    x_msg_data  := x_msg_data || l_msg_data || '*';
		end if;
		x_msg_data := x_msg_data || '*' || l_result_rec.result_code;
		ROLLBACK TO ARI_Create_Cash_PVT;
		write_error_messages(x_msg_data, x_msg_count);
		RETURN;
	END IF;

   END IF;

  p_status := FND_API.G_RET_STS_SUCCESS;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,
                 'End-');
  end if;

EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('- Customer Id: '||p_customer_id);
      write_debug_and_log('- Customer Site Id: '||p_site_use_id);
      write_debug_and_log('- Cash Receipt Id: '||p_cash_receipt_id);
      write_debug_and_log('- Return Status: '||p_status);
      write_debug_and_log('ERROR =>'|| SQLERRM);

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

      p_status := FND_API.G_RET_STS_ERROR;
      write_error_messages(x_msg_data, x_msg_count);

END pay_multiple_invoices;


/*==============================================================
 | PROCEDURE process_payment
 |
 | DESCRIPTION
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |   This procedure is the same as the on in the ar_receipt_api_pub.
 |   It was duplicated here in order to avoid exposing the api as a
 |   public api.
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 13-Jan-2003   krmenon      Created
 | 25-Feb-2004   vnb          Modified to add 'org_id' to rct_info
 |                            cursor,to be passed onto iPayment API
 | 07-Oct-2004   vnb          Bug 3335944 - One Time Credit Card Verification
 |
 +==============================================================*/
PROCEDURE process_payment(
	        p_cash_receipt_id     IN  NUMBER,
	        p_payer_rec           IN  IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
	        P_payee_rec           IN  IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type,
                p_called_from         IN  VARCHAR2,
                p_response_error_code OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
	        x_return_status       OUT NOCOPY VARCHAR2
                ) IS

  CURSOR rct_info_cur IS
     SELECT cr.receipt_number,
	    cr.amount,
            cr.currency_code,
            rc.creation_status,
            cr.org_id,cr.payment_trxn_extension_id,
            cr.receipt_method_id
     FROM   ar_cash_receipts cr,
            ar_receipt_methods rm,
	    ar_receipt_classes rc
     WHERE  cr.cash_receipt_id = p_cash_receipt_id
       AND  cr.receipt_method_id = rm.receipt_method_id
       and  rm.receipt_class_id = rc.receipt_class_id;


  rct_info rct_info_cur%ROWTYPE;

  l_cr_rec ar_cash_receipts%ROWTYPE;



l_auth_rec        IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
l_amount_rec      IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
x_auth_result     IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;
x_response	  IBY_FNDCPT_COMMON_PUB.Result_rec_type;

l_payment_trxn_extension_id number;

  l_action VARCHAR2(80);

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);
  l_procedure_name VARCHAR2(30);
  l_debug_info	   VARCHAR2(200);

BEGIN
  --Assign default values
  l_return_status  := FND_API.G_RET_STS_SUCCESS;
  l_procedure_name := '.process_payment';

  arp_standard.debug('Entering credit card processing...'||p_cash_receipt_id);
  ---------------------------------------------------------------------------------
  l_debug_info := 'Entering credit card processing';
  ---------------------------------------------------------------------------------
  OPEN rct_info_cur;
  FETCH rct_info_cur INTO rct_info;

  IF rct_info_cur%FOUND THEN
        ---------------------------------------------------------------------------------
        l_debug_info := 'This is a credit card account - determining if capture is necessary';
        ---------------------------------------------------------------------------------
        write_debug_and_log('l_debug_info');

        -- determine whether to AUTHORIZE only or to
        -- CAPTURE and AUTHORIZE in one step.  This is
        -- dependent on the receipt creation status, i.e.,
        -- if the receipt is created as remitted or cleared, the
        -- funds need to be authorized and captured.  If the
        -- receipt is confirmed, the remittance process will
        -- handle the capture and at this time we'll only
        -- authorize the charges to the credit card.

        if rct_info.creation_status IN ('REMITTED', 'CLEARED') THEN
          l_action := 'AUTHANDCAPTURE';
        elsif rct_info.creation_status = 'CONFIRMED' THEN
          l_action := 'AUTHONLY';
        else
          arp_standard.debug('ERROR: Creation status is ' || rct_info.creation_status);
          FND_MESSAGE.set_name('AR', 'AR_PAY_PROCESS_INVALID_STATUS');
          FND_MSG_PUB.Add;

          x_return_status := FND_API.G_RET_STS_ERROR;  -- should never happen
          RETURN;
        end if;
        l_payment_trxn_extension_id:= rct_info.payment_trxn_extension_id;
        -- Step 1: (always performed):
        -- authorize credit card charge

        ---------------------------------------------------------------------------------
        l_debug_info := 'Authorize credit card charge: set auth record';
        ---------------------------------------------------------------------------------

     l_auth_rec.Memo := NULL;
     l_auth_rec.Order_Medium := NULL;
     l_auth_rec.ShipFrom_SiteUse_Id  := NULL;
     l_auth_rec.ShipFrom_PostalCode := NULL;
     l_auth_rec.ShipTo_SiteUse_Id  := NULL;
     l_auth_rec.ShipTo_PostalCode := NULL;
     l_auth_rec.RiskEval_Enable_Flag  := NULL;

     l_amount_rec.Value     := rct_info.amount;
     l_amount_rec.Currency_Code := rct_info.currency_code;

      /*Bug 8263633 pass receipt method id as per IBY requirement*/
      l_auth_rec.receipt_method_id := rct_info.receipt_method_id;

        -- call to iPayment API OraPmtReq to authorize funds
        write_debug_and_log('Calling Create_Authorization');
        write_debug_and_log('p_trxn_entity_id: ' || l_PAYMENT_TRXN_EXTENSION_ID);
        write_debug_and_log('p_payer_rec.payment_function:' || p_payer_rec.payment_function);
        write_debug_and_log('p_payer_rec.org_type: ' ||  p_payer_rec.org_type);
        write_debug_and_log('p_payer_rec.Cust_Account_Id: ' || p_payer_rec.Cust_Account_Id);
        write_debug_and_log('p_payer_rec.Account_Site_Id: ' ||p_payer_rec.Account_Site_Id );
	write_debug_and_log('l_amount_rec.Value: ' || to_char(l_amount_rec.Value) );
        write_debug_and_log('l_amount_rec.Currency_Code: ' ||l_amount_rec.Currency_Code );
        write_debug_and_log('p_payee_rec.org_type: ' || p_payee_rec.org_type);
        write_debug_and_log('p_payee_rec.org_id : ' || p_payee_rec.org_id  );
        write_debug_and_log('l_auth_rec.receipt_method_id : ' || l_auth_rec.receipt_method_id  );
	    write_debug_and_log('p_payee_rec.Int_Bank_Country_Code : ' || p_payee_rec.Int_Bank_Country_Code  );

        ---------------------------------------------------------------------------------
        l_debug_info := 'Call to iPayment API to authorize funds';
        ---------------------------------------------------------------------------------


        IBY_FNDCPT_TRXN_PUB.Create_Authorization(
		    p_api_version	         => 1.0,
		    p_init_msg_list		 => FND_API.G_TRUE,
		    x_return_status		 => l_return_status,
		    x_msg_count			 => l_msg_count,
		    x_msg_data		         => l_msg_data,
		    p_payer			 => p_payer_rec,
		    p_payee			 => p_payee_rec,
		    p_trxn_entity_id		 => l_PAYMENT_TRXN_EXTENSION_ID,
		    p_auth_attribs		 => l_auth_rec,
		    p_amount			 => l_amount_rec,
		    x_auth_result		 => x_auth_result,
		    x_response			 => x_response);

    	 arp_standard.debug('l_return_status: ' || l_return_status);

         x_msg_count           := l_msg_count;
         x_msg_data            := l_msg_data;
         p_response_error_code := x_response.Result_Code ;

         write_debug_and_log('-------------------------------------');
         write_debug_and_log('x_response.Result_Code: ' || x_response.Result_Code);
         write_debug_and_log('x_response.Result_Message: ' || x_response.Result_Message);
         write_debug_and_log('x_response.Result_Category: ' || x_response.Result_Category);
         write_debug_and_log('x_auth_result.Auth_Id : ' || x_auth_result.Auth_Id );
         write_debug_and_log('x_auth_result.Auth_Date: ' || TO_CHAR(x_auth_result.Auth_Date));
	 write_debug_and_log('x_auth_result.Auth_Code: ' || x_auth_result.Auth_Code);
	 write_debug_and_log('x_auth_result.AVS_Code: ' || x_auth_result.AVS_Code);
	 write_debug_and_log('x_auth_result.Instr_SecCode_Check: ' || x_auth_result.Instr_SecCode_Check);
	 write_debug_and_log('x_auth_result.PaymentSys_Code: ' || x_auth_result.PaymentSys_Code);
	 write_debug_and_log('x_auth_result.PaymentSys_Msg: ' || x_auth_result.PaymentSys_Msg);
         write_debug_and_log('-------------------------------------');

        -- check if call was successful
        --Add message to message stack only it it is called from iReceivables
        --if not pass the message stack received from iPayment

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           AND (NVL(p_called_from,'NONE') = 'IREC')  then

          FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
          FND_MSG_PUB.Add;
          x_return_status := l_return_status;
             --Bug 7673372 - When IBY API throws an error without contacting 3rd pmt system the error msg would
             --returned in x_response.Result_Message;
           x_msg_data := x_response.Result_Message;
          RETURN;
        elsif (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RETURN;
        end if;

        -- update cash receipt with authorization code
         ---------------------------------------------------------------------------------
        l_debug_info := 'update cash receipt with authorization code and payment server order id';
        ---------------------------------------------------------------------------------

        ARP_CASH_RECEIPTS_PKG.set_to_dummy(l_cr_rec);
        l_cr_rec.approval_code := x_auth_result.Auth_Code;
        ARP_CASH_RECEIPTS_PKG.update_p(l_cr_rec, p_cash_receipt_id);

          write_debug_and_log('CR rec updated with payment server auth code');

        -- see if capture is also required

        if (l_action = 'AUTHANDCAPTURE') then

          write_debug_and_log('starting capture...');
          ---------------------------------------------------------------------------------
          l_debug_info := 'Capture required: capture funds';
          ---------------------------------------------------------------------------------
          -- Step 2: (optional): capture funds

           ---------------------------------------------------------------------------------
          l_debug_info := 'Call iPayment API to capture funds';
          ---------------------------------------------------------------------------------
          IBY_FNDCPT_TRXN_PUB.Create_Settlement(
		    p_api_version           => 1.0,
		    p_init_msg_list         => FND_API.G_TRUE,
		    x_return_status         => l_return_status,
		    x_msg_count             => l_msg_count,
		    x_msg_data              => l_msg_data,
		    p_payer		    => p_payer_rec,
		    p_trxn_entity_id	    => l_PAYMENT_TRXN_EXTENSION_ID,
		    p_amount                => l_amount_rec,
		    x_response              => x_response);


            write_debug_and_log('CAPTURE l_return_status: ' || l_return_status);

            x_msg_count           := l_msg_count;
            x_msg_data            := l_msg_data;
            p_response_error_code := x_response.Result_Code;

            arp_standard.debug('-------------------------------------');
            arp_standard.debug('x_response.Result_Code: ' ||x_response.Result_Code);
            arp_standard.debug('x_response.Result_Category: ' || x_response.Result_Category);
            arp_standard.debug('x_response.Result_Message: ' || x_response.Result_Message);

            arp_standard.debug('-------------------------------------');

           --Add message to message stack only it it is called from iReceivables
           --if not pass the message stack received from iPayment

           if (l_return_status <> FND_API.G_RET_STS_SUCCESS) AND (NVL(p_called_from,'NONE') = 'IREC')  then
              FND_MESSAGE.set_name('AR', 'AR_CC_CAPTURE_FAILED');
              FND_MSG_PUB.Add;
           end if;
           x_return_status := l_return_status;
             --Bug 7673372 - When IBY API throws an error without contacting 3rd pmt system the error msg would
             --returned in x_response.Result_Message;
           x_msg_data := x_response.Result_Message;

        END IF;  -- if capture required...

      ELSE

        write_debug_and_log('should never come here --> receipt method cursor has no rows');
        -- currently no processing required

    END IF;

EXCEPTION
    WHEN OTHERS THEN
    	BEGIN
	    x_return_status := FND_API.G_RET_STS_ERROR;

            write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
            write_debug_and_log('- Cash Receipt Id: '||p_cash_receipt_id);
            write_debug_and_log('- Return Status: '||x_return_status);
            write_debug_and_log(SQLERRM);

            FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
            FND_MSG_PUB.ADD;
        END;

END process_payment;


FUNCTION validate_payment_setup (p_customer_id IN NUMBER , p_customer_site_id IN NUMBER , p_currency_code IN VARCHAR2) RETURN NUMBER
IS

  l_ccmethodcount NUMBER;
  l_bamethodcount NUMBER; /* J Rautiainen ACH Implementation */
  l_creation_status ar_receipt_classes.creation_status%TYPE;
  l_procedure_name VARCHAR2(30);
BEGIN

  l_procedure_name  := '.validate_payment_setup';

  -- check that function security is allowing access to payment button

  IF NOT fnd_function.test('ARW_PAY_INVOICE') THEN
    RETURN 0;
  END IF;

  -- verify that payment method is set up
  l_ccmethodcount  := is_credit_card_payment_enabled(p_customer_id , p_customer_site_id , p_currency_code) ;

  -- Bug 3338276
  -- If one-time payment is enabled, bank account payment is not enabled;
  -- Hence, the check for valid bank account payment methods can be defaulted to 0.
  -- Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.save_payment_instrument_info
  IF NOT ARI_UTILITIES.save_payment_instrument_info(p_customer_id , p_customer_site_id) THEN
    l_bamethodcount := 0;
  ELSE
    l_bamethodcount := is_bank_acc_payment_enabled(p_customer_id , p_customer_site_id , p_currency_code);
  END IF;

   IF   l_ccmethodcount  = 0
   AND l_bamethodcount = 0  /* J Rautiainen ACH Implementation */
   THEN
    RETURN 0;
  END IF;

  RETURN 1;

END validate_payment_setup;

/*============================================================
  | PUBLIC procedure create_transaction_list_record
  |
  | DESCRIPTION
  |   Creates a record in the transaction List to be paid by the customer
  |   based on the selected list .
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_payment_schedule_id   IN    NUMBER
  |   p_customer_id	      IN    NUMBER
  |   p_customer_site_id      IN    NUMBER
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 27-JUN-2003   yreddy       Created
  | 31-DEC-2004   vnb          Bug 4071551 - Modified for avoiding redundant code
  | 20-Jan-2005   vnb          Bug 4117211 - Original discount amount column added for ease of resetting payment amounts
  | 26-May-05     rsinthre     Bug # 4392371 - OIR needs to support cross customer payment
  | 08-Jul-2005	  rsinthre     Bug 4437225 - Disputed amount against invoice not displayed during payment
  | 08-Jun-2010  nkanchan Bug # 9696274 - PAGE ERRORS OUT ON NAVIGATING 'PAY BELOW' RELATED CUSTOMER DATA
  +============================================================*/
PROCEDURE create_transaction_list_record( p_payment_schedule_id   IN NUMBER,
					  p_customer_id           IN NUMBER,
					  p_customer_site_id	  IN NUMBER
                                  ) IS

  l_query_period             NUMBER(15);
  l_query_date               DATE;
  l_total_service_charge     NUMBER;
  l_discount_amount          NUMBER;
  l_rem_amt_rcpt             NUMBER;
  l_rem_amt_inv              NUMBER;
  l_amount_due_remaining     NUMBER;
  l_trx_class                VARCHAR2(20);
  l_cash_receipt_id          NUMBER;
  l_grace_days_flag          VARCHAR2(2);

  l_pay_for_cust_id	     NUMBER(15);
  l_paying_cust_id	     NUMBER(15);
  l_pay_for_cust_site_id     NUMBER(15);
  l_paying_cust_site_id      NUMBER(15);
  l_dispute_amount	     NUMBER := 0;
  l_customer_trx_id	     NUMBER(15,0);

  l_procedure_name           VARCHAR2(50);
  l_debug_info	 	     VARCHAR2(200);

BEGIN
  --Assign default values
  l_query_period         := -12;
  l_total_service_charge := 0;
  l_discount_amount      := 0;
  l_rem_amt_rcpt         := 0;
  l_rem_amt_inv          := 0;
  l_amount_due_remaining := 0;

  l_procedure_name       := '.create_transaction_list_record';

  SAVEPOINT create_trx_list_record_sp;

  select class, amount_due_remaining, cash_receipt_id, ps.CUSTOMER_ID, ct.PAYING_CUSTOMER_ID, ps.CUSTOMER_SITE_USE_ID,ct.PAYING_SITE_USE_ID, ps.customer_trx_id,
    (decode( nvl(AMOUNT_DUE_ORIGINAL,0),0,1,(AMOUNT_DUE_ORIGINAL/abs(AMOUNT_DUE_ORIGINAL)) ) *abs(nvl(amount_in_dispute,0)) )
  into l_trx_class, l_amount_due_remaining, l_cash_receipt_id, l_pay_for_cust_id, l_paying_cust_id, l_pay_for_cust_site_id, l_paying_cust_site_id, l_customer_trx_id, l_dispute_amount
  from ar_payment_schedules ps, ra_customer_trx_all ct
  where ps.CUSTOMER_TRX_ID = ct.CUSTOMER_TRX_ID(+)
  and ps.payment_schedule_id = p_payment_schedule_id;

   --Bug 4479224
   l_paying_cust_id := p_customer_id;
   --l_paying_cust_site_id := p_customer_site_id;
   --Commented for bug 9696274
   if( p_customer_site_id IS NULL OR p_customer_site_id = '' OR p_customer_site_id = -1) then
      if(l_paying_cust_id = l_pay_for_cust_id) then
         l_paying_cust_site_id := l_pay_for_cust_site_id;
      else
         l_paying_cust_site_id := -1;
      end if;
   else
      l_paying_cust_site_id := p_customer_site_id;
   end if;

  ----------------------------------------------------------------------------------------
  l_debug_info := 'If the transaction is a Payment, then set the Remaining Amount';
  -----------------------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
  END IF;
  -- Bug 4000279 - Modified to check for 'UNAPP' status only
  IF (l_trx_class = 'PMT') THEN

	select -sum(app.amount_applied)
        into  l_amount_due_remaining
 	from ar_receivable_applications app
	where nvl( app.confirmed_flag, 'Y' ) = 'Y'
        and app.status = 'UNAPP'
        and app.cash_receipt_id = l_cash_receipt_id;
   ----------------------------------------------------------------------------------------
   l_debug_info := 'If the transaction is a debit, then calculate discount';
   -----------------------------------------------------------------------------------------
   IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
   END IF;
   ELSIF (l_trx_class = 'INV' OR l_trx_class = 'DEP' OR l_trx_class = 'DM' OR l_trx_class = 'CB') THEN
	  --Bug 6819964 - If AR API errors out then payments are failing as l_discount_amount is not set to any value
	  begin
        	--l_grace_days_flag := is_grace_days_enabled_wrapper();
        	l_grace_days_flag := ARI_UTILITIES.is_discount_grace_days_enabled(p_customer_id,p_customer_site_id);
        	arp_discounts_api.get_discount(p_ps_id	            => p_payment_schedule_id,
		                       p_apply_date	    => trunc(sysdate),
                            	       p_in_applied_amount  => (l_amount_due_remaining - l_dispute_amount),
		                       p_grace_days_flag    => l_grace_days_flag,
		                       p_out_discount       => l_discount_amount,
		                       p_out_rem_amt_rcpt   => l_rem_amt_rcpt,
		                       p_out_rem_amt_inv    => l_rem_amt_inv,
				       p_called_from        => 'OIR' );
	  exception
		when others then
			l_discount_amount := 0;
			write_debug_and_log('Unexpected Exception while calculating discount');
			write_debug_and_log('Payment Schedule Id: '||p_payment_schedule_id);
	  end;
   END IF;

    --Bug 4117211 - Original discount amount column added for ease of resetting payment amounts
    ----------------------------------------------------------------------------------------
    l_debug_info := 'Populate the Payment GT with the transaction';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    INSERT INTO AR_IREC_PAYMENT_LIST_GT
      ( CUSTOMER_ID,
        CUSTOMER_SITE_USE_ID,
        ACCOUNT_NUMBER,
        CUSTOMER_TRX_ID,
        TRX_NUMBER,
        PAYMENT_SCHEDULE_ID,
        TRX_DATE,
        DUE_DATE,
        STATUS,
        TRX_CLASS,
        PO_NUMBER,
        SO_NUMBER,
        CURRENCY_CODE,
        AMOUNT_DUE_ORIGINAL,
        AMOUNT_DUE_REMAINING,
        DISCOUNT_AMOUNT,
        SERVICE_CHARGE,
        PAYMENT_AMT,
        PAYMENT_TERMS,
        NUMBER_OF_INSTALLMENTS,
        TERMS_SEQUENCE_NUMBER,
        LINE_AMOUNT,
        TAX_AMOUNT,
        FREIGHT_AMOUNT,
        FINANCE_CHARGES,
        RECEIPT_DATE,
        PRINTING_OPTION,
	INTERFACE_HEADER_CONTEXT,
        INTERFACE_HEADER_ATTRIBUTE1,
        INTERFACE_HEADER_ATTRIBUTE2,
        INTERFACE_HEADER_ATTRIBUTE3,
        INTERFACE_HEADER_ATTRIBUTE4,
        INTERFACE_HEADER_ATTRIBUTE5,
        INTERFACE_HEADER_ATTRIBUTE6,
        INTERFACE_HEADER_ATTRIBUTE7,
        INTERFACE_HEADER_ATTRIBUTE8,
        INTERFACE_HEADER_ATTRIBUTE9,
        INTERFACE_HEADER_ATTRIBUTE10,
        INTERFACE_HEADER_ATTRIBUTE11,
        INTERFACE_HEADER_ATTRIBUTE12,
        INTERFACE_HEADER_ATTRIBUTE13,
        INTERFACE_HEADER_ATTRIBUTE14,
        INTERFACE_HEADER_ATTRIBUTE15,
        ATTRIBUTE_CATEGORY,
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
        CASH_RECEIPT_ID,
	ORIGINAL_DISCOUNT_AMT,
    ORG_ID,
	PAY_FOR_CUSTOMER_ID,
	PAY_FOR_CUSTOMER_SITE_ID,
	DISPUTE_AMT
      )
       SELECT l_paying_cust_id,
         decode(l_paying_cust_site_id, null, -1,to_number(''), -1, l_paying_cust_site_id),
         acct.ACCOUNT_NUMBER,
         ps.CUSTOMER_TRX_ID,
         ps.TRX_NUMBER,
         ps.PAYMENT_SCHEDULE_ID,
         ps.TRX_DATE,
         ps.DUE_DATE,
         ps.STATUS,
         ps.class,
         ct.PURCHASE_ORDER AS PO_NUMBER,
         NULL AS SO_NUMBER,
	 ps.INVOICE_CURRENCY_CODE,
	 ps.AMOUNT_DUE_ORIGINAL,
         l_amount_due_remaining,
	 l_discount_amount,
	 0,
	 DECODE(ps.class, 'PMT', l_amount_due_remaining, 'CM', l_amount_due_remaining,
			ARI_UTILITIES.curr_round_amt(l_amount_due_remaining-l_discount_amount -l_dispute_amount,ps.INVOICE_CURRENCY_CODE)),
         trm.name term_desc,
	 ARPT_SQL_FUNC_UTIL.Get_Number_Of_Due_Dates(ps.term_id) number_of_installments,
         ps.terms_sequence_number,
         ps.amount_line_items_original line_amount,
         ps.tax_original tax_amount,
         ps.freight_original freight_amount,
         ps.receivables_charges_charged finance_charge,
         TRUNC(SYSDATE) receipt_date,
         ct.printing_option,
	 ct.INTERFACE_HEADER_CONTEXT,
         ct.INTERFACE_HEADER_ATTRIBUTE1,
         ct.INTERFACE_HEADER_ATTRIBUTE2,
         ct.INTERFACE_HEADER_ATTRIBUTE3,
         ct.INTERFACE_HEADER_ATTRIBUTE4,
         ct.INTERFACE_HEADER_ATTRIBUTE5,
         ct.INTERFACE_HEADER_ATTRIBUTE6,
         ct.INTERFACE_HEADER_ATTRIBUTE7,
         ct.INTERFACE_HEADER_ATTRIBUTE8,
         ct.INTERFACE_HEADER_ATTRIBUTE9,
         ct.INTERFACE_HEADER_ATTRIBUTE10,
         ct.INTERFACE_HEADER_ATTRIBUTE11,
         ct.INTERFACE_HEADER_ATTRIBUTE12,
         ct.INTERFACE_HEADER_ATTRIBUTE13,
         ct.INTERFACE_HEADER_ATTRIBUTE14,
         ct.INTERFACE_HEADER_ATTRIBUTE15,
         ct.ATTRIBUTE_CATEGORY,
         ct.ATTRIBUTE1,
         ct.ATTRIBUTE2,
         ct.ATTRIBUTE3,
         ct.ATTRIBUTE4,
         ct.ATTRIBUTE5,
         ct.ATTRIBUTE6,
         ct.ATTRIBUTE7,
         ct.ATTRIBUTE8,
         ct.ATTRIBUTE9,
         ct.ATTRIBUTE10,
         ct.ATTRIBUTE11,
         ct.ATTRIBUTE12,
         ct.ATTRIBUTE13,
         ct.ATTRIBUTE14,
         ct.ATTRIBUTE15,
         ps.cash_receipt_id,
	 l_discount_amount,
	 ps.org_id,
	 l_pay_for_cust_id,
	 --Bug 4062938 - Handling of transactions with no site id
	 decode(ps.customer_site_use_id, null, -1,ps.customer_site_use_id) as CUSTOMER_SITE_USE_ID,
	 (decode( nvl(ps.AMOUNT_DUE_ORIGINAL,0),0,1,(ps.AMOUNT_DUE_ORIGINAL/abs(ps.AMOUNT_DUE_ORIGINAL)) ) *abs(nvl(ps.amount_in_dispute,0)) )
      FROM AR_PAYMENT_SCHEDULES ps,
           RA_CUSTOMER_TRX_ALL ct,
           HZ_CUST_ACCOUNTS acct,
           RA_TERMS trm
      WHERE ps.payment_schedule_id = p_payment_schedule_id
      AND   ps.CLASS IN ('INV', 'DM', 'GUAR', 'CB', 'DEP', 'CM', 'PMT' )  -- CCA - hikumar
      AND   ps.customer_trx_id = ct.customer_trx_id(+)
      AND   acct.cust_account_id = ps.customer_id
      AND   ps.term_id = trm.term_id(+);

   COMMIT;

EXCEPTION
     WHEN OTHERS THEN
         IF (PG_DEBUG = 'Y') THEN
             arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
             arp_standard.debug('- Payment Schedule Id: '||p_payment_schedule_id);
             arp_standard.debug('ERROR =>'|| SQLERRM);
         END IF;

	 ROLLBACK to create_trx_list_record_sp;

         FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
         FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
         FND_MSG_PUB.ADD;

END create_transaction_list_record;

/*========================================================================
 | PUBLIC procedure is_credit_card_payment_enabled
 |
 | DESCRIPTION
 |      Checks if the credit card payment method has been setup
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      Number 1 or 0 corresponing to true and false for the credit card
 |      payment has been setup or not.
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 10-Mar-2004   hikumar       Created
 ========================================================================*/

FUNCTION is_credit_card_payment_enabled(p_customer_id IN NUMBER , p_customer_site_id IN NUMBER , p_currency_code IN VARCHAR2)
RETURN NUMBER IS
system_cc_payment_method	NUMBER ;
customer_cc_payment_method      NUMBER ;
profile_cc_payment_method VARCHAR2(200);

CURSOR cc_profile_pmt_method_info_cur IS
  SELECT arm.receipt_method_id receipt_method_id,
    arc.creation_status receipt_creation_status
  FROM ar_receipt_methods arm,
    ar_receipt_method_accounts arma,
    ce_bank_acct_uses_ou_v aba,
    ce_bank_accounts       cba,
    ar_receipt_classes arc
  WHERE arm.payment_channel_code = 'CREDIT_CARD'
    AND arm.receipt_method_id = NVL( to_number(fnd_profile.VALUE('OIR_CC_PMT_METHOD')), arm.receipt_method_id)
    AND arm.receipt_method_id = arma.receipt_method_id
    AND arm.receipt_class_id = arc.receipt_class_id
    AND arma.remit_bank_acct_use_id = aba.bank_acct_use_id
    AND aba.bank_account_id = cba.bank_account_id
    AND (cba.currency_code = p_currency_code OR cba.receipt_multi_currency_flag = 'Y')
    AND TRUNC(nvl(aba.end_date,sysdate)) >= TRUNC(sysdate)
    AND TRUNC(sysdate) BETWEEN TRUNC(nvl(arm.start_date,   sysdate)) AND TRUNC(nvl(arm.end_date,   sysdate))
    AND TRUNC(sysdate) BETWEEN TRUNC(arma.start_date) AND TRUNC(nvl(arma.end_date,   sysdate));



 cc_profile_pmt_method_info cc_profile_pmt_method_info_cur%ROWTYPE;

 l_procedure_name  VARCHAR2(30);
 l_debug_info  VARCHAR2(300);

BEGIN

l_procedure_name := 'is_credit_card_payment_enabled';

   --------------------------------------------------------------------
   l_debug_info := 'Checking if valid CC payment method is set in the profile OIR_CC_PMT_METHOD';
   --------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
     END IF;

  profile_cc_payment_method := FND_PROFILE.value('OIR_CC_PMT_METHOD');

  IF (profile_cc_payment_method = 'DISABLED') THEN   /* Credit Card Payment is Disabled */
    RETURN 0;
  ELSIF (profile_cc_payment_method IS NOT NULL) THEN /* A Credit Card Payment Method has been mentioned */
    OPEN  cc_profile_pmt_method_info_cur;
    FETCH cc_profile_pmt_method_info_cur INTO cc_profile_pmt_method_info;
    /* If CC Payment Method set is NULL or DISABLED or an invalid payment method, it returns NO rows */
    IF cc_profile_pmt_method_info_cur%FOUND THEN
       l_debug_info := 'Payment Method Set in the profile OIR_CC_PMT_METHOD is Valid. Val=' ||  fnd_profile.VALUE('OIR_CC_PMT_METHOD');
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
        end if;
      RETURN 1;
     ELSE
      l_debug_info := 'Invalid Payment Method is Set in the profile OIR_CC_PMT_METHOD. Value in profile=' ||  fnd_profile.VALUE('OIR_CC_PMT_METHOD');
       if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
       end if;
      RETURN 0;
    END IF;
   CLOSE cc_profile_pmt_method_info_cur;

  END IF;

  l_debug_info := 'No value is set in the profile OIR_CC_PMT_METHOD. Checking at customer site, acct and system options level.';

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
     end if;

 /* Default behavior, as no Credit Card Payment method is mentioned in the OIR_CC_PMT_METHOD profile */

 -- verify that Credit Card payment method is set up in AR_SYSTEM_PARAMETERS
  -- Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.save_payment_instrument_info
  SELECT  /*+ leading(rc) */  count(irec_cc_receipt_method_id)
  INTO system_cc_payment_method
  FROM   ar_system_parameters sp,
         ar_receipt_methods rm,
         ar_receipt_method_accounts rma,
         ce_bank_accounts cba,
         ce_bank_acct_uses_ou_v ba,
         ar_receipt_classes rc
  WHERE  sp.irec_cc_receipt_method_id = rm.receipt_method_id
    AND  rma.receipt_method_id = rm.receipt_method_id
    AND  rma.remit_bank_acct_use_id = ba.bank_acct_use_id
    AND  ba.bank_account_id = cba.bank_account_id
    AND  ( cba.currency_code = p_currency_code
	    OR
	   cba.receipt_multi_currency_flag = 'Y' )
    AND  sysdate < nvl(ba.end_date, SYSDATE+1)
    AND  sysdate between rma.start_date and nvl(rma.end_date, SYSDATE)
    AND  sysdate between rm.start_date and NVL(rm.end_date, SYSDATE)
     AND (
           save_payment_inst_info_wrapper(p_customer_id,p_customer_site_id) = 'true'
          OR
             -- If the one time payment is true , then ensure that the receipt
              -- class is set for one step remittance.
              rc.creation_status IN ('REMITTED','CLEARED'))
              and rc.receipt_class_id = rm.receipt_class_id;

 -- verify that Credit Card payment method is set up at Customer Account Level or Site Level

  SELECT count ( arm.receipt_method_id )
  INTO customer_cc_payment_method
  FROM    ar_receipt_methods         arm,
          ra_cust_receipt_methods    rcrm,
          ar_receipt_method_accounts arma,
          ce_bank_acct_uses_ou_v          aba,
          ce_bank_accounts           cba,
          ar_receipt_classes         arc
  WHERE   arm.receipt_method_id = rcrm.receipt_method_id
     AND       arm.receipt_method_id = arma.receipt_method_id
     AND       arm.receipt_class_id  = arc.receipt_class_id
     AND       rcrm.customer_id      = p_customer_id
     AND       arma.remit_bank_acct_use_id = aba.bank_acct_use_id
     AND       aba.bank_account_id = cba.bank_account_id
     AND     ( NVL(rcrm.site_use_id,p_customer_site_id)  = p_customer_site_id
               OR
               (p_customer_site_id is null and rcrm.site_use_id is null)
              )
     AND   (
                 cba.currency_code    =  p_currency_code
                 OR
                 cba.receipt_multi_currency_flag = 'Y'
              )
-- Bug#6109909
--     AND  arm.payment_type_code = 'CREDIT_CARD'
     AND  arm.payment_channel_code = 'CREDIT_CARD'
     AND  arc.creation_method_code = 'AUTOMATIC'
     -- AND       aba.set_of_books_id = arp_trx_global.system_info.system_parameters.set_of_books_id
     AND sysdate < NVL ( aba.end_date , sysdate+1)
     AND sysdate between arm.start_date AND NVL(arm.end_date, sysdate)
     AND sysdate between arma.start_date AND NVL(arma.end_date, sysdate)
     AND (
          ( save_payment_inst_info_wrapper(p_customer_id,p_customer_site_id) = 'true' )
          OR
          (   -- If the one time payment is true , then ensure that the receipt
              -- class is set for one step remittance.
            arc.creation_status IN ('REMITTED','CLEARED')
          )
         )
      ;

  IF( (customer_cc_payment_method = 0 ) AND  (system_cc_payment_method = 0))
  THEN
    RETURN 0 ;
  ELSE
    RETURN 1 ;
  END IF;

EXCEPTION
WHEN OTHERS THEN
        l_debug_info := 'Unknown exception. Value in profile OIR_CC_PMT_METHOD=' ||  fnd_profile.VALUE('OIR_CC_PMT_METHOD');
        write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
       	write_debug_and_log('ERROR =>'|| SQLERRM);
        write_debug_and_log('-DEBUG_INFO-' || l_debug_info);
        RETURN 0;

END is_credit_card_payment_enabled ;




/*========================================================================
 | PUBLIC procedure is_bank_acc_payment_enabled
 |
 | DESCRIPTION
 |      Checks if the Bank Account payment method has been setup
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      Number 1 or 0 corresponing to true and false for the credit card
 |      payment has been setup or not.
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 10-Mar-2004   hikumar       Created
 ========================================================================*/

FUNCTION is_bank_acc_payment_enabled(p_customer_id IN NUMBER , p_customer_site_id IN NUMBER , p_currency_code IN VARCHAR2)
RETURN NUMBER IS
system_bank_payment_method  	NUMBER ;
customer_bank_payment_method    NUMBER ;
profile_ba_payment_method VARCHAR2(200);

CURSOR ba_profile_pmt_method_info_cur IS
  SELECT arm.receipt_method_id receipt_method_id,
    arc.creation_status receipt_creation_status
  FROM ar_receipt_methods arm,
    ar_receipt_method_accounts arma,
    ce_bank_acct_uses_ou_v aba,
    ce_bank_accounts       cba,
    ar_receipt_classes arc
  WHERE NVL(arm.payment_channel_code,'NONE') <> 'CREDIT_CARD'
    AND arm.receipt_method_id = NVL( to_number(fnd_profile.VALUE('OIR_BA_PMT_METHOD')), arm.receipt_method_id)
    AND arm.receipt_method_id = arma.receipt_method_id
    AND arm.receipt_class_id = arc.receipt_class_id
    AND arma.remit_bank_acct_use_id = aba.bank_acct_use_id
    AND aba.bank_account_id = cba.bank_account_id
    AND (cba.currency_code = p_currency_code OR cba.receipt_multi_currency_flag = 'Y')
    AND TRUNC(nvl(aba.end_date,sysdate)) >= TRUNC(sysdate)
    AND TRUNC(sysdate) BETWEEN TRUNC(nvl(arm.start_date,   sysdate)) AND TRUNC(nvl(arm.end_date,   sysdate))
    AND TRUNC(sysdate) BETWEEN TRUNC(arma.start_date) AND TRUNC(nvl(arma.end_date,   sysdate));

 ba_profile_pmt_method_info ba_profile_pmt_method_info_cur%ROWTYPE;

 l_procedure_name  VARCHAR2(30);
 l_debug_info  VARCHAR2(300);

BEGIN

l_procedure_name := 'is_bank_acc_payment_enabled';

   --------------------------------------------------------------------
   l_debug_info := 'Checking if valid Bank Account payment method is set in the profile OIR_BA_PMT_METHOD';
   --------------------------------------------------------------------
     IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
     END IF;

  profile_ba_payment_method := FND_PROFILE.value('OIR_BA_PMT_METHOD');

  IF (profile_ba_payment_method = 'DISABLED') THEN   /* Bank Account Payment is Disabled */
    RETURN 0;
  ELSIF (profile_ba_payment_method IS NOT NULL) THEN /* A Bank Account Payment Method has been mentioned */
    OPEN  ba_profile_pmt_method_info_cur;
    FETCH ba_profile_pmt_method_info_cur INTO ba_profile_pmt_method_info;
    /* If Bank Account Payment Method set is NULL or DISABLED or an invalid payment method, it returns NO rows */
    IF ba_profile_pmt_method_info_cur%FOUND THEN
       l_debug_info := 'Payment Method Set in the profile OIR_BA_PMT_METHOD is Valid. Val=' ||  fnd_profile.VALUE('OIR_BA_PMT_METHOD');
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
        end if;
      RETURN 1;
     ELSE
      l_debug_info := 'Invalid Payment Method is Set in the profile OIR_BA_PMT_METHOD. Value in profile=' ||  fnd_profile.VALUE('OIR_BA_PMT_METHOD');
       if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
       end if;
      RETURN 0;
    END IF;
   CLOSE ba_profile_pmt_method_info_cur;

  END IF;

  l_debug_info := 'No value is set in the profile OIR_BA_PMT_METHOD. Checking at customer site, acct and system options level.';

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, l_debug_info);
     end if;

 /* Default behavior, as no Bank Account Payment method is mentioned in the OIR_BA_PMT_METHOD profile */

 -- verify that Bank Account payment method is set up in AR_SYSTEM_PARAMETERS

  SELECT count(irec_ba_receipt_method_id) /* J Rautiainen ACH Implementation */
  INTO system_bank_payment_method
  FROM   ar_system_parameters sp,
         ar_receipt_methods rm,
         ar_receipt_method_accounts rma,
         ce_bank_acct_uses_ou_v ba,
         ce_bank_accounts cba
  WHERE  sp.irec_ba_receipt_method_id = rm.receipt_method_id
    AND  rma.receipt_method_id = rm.receipt_method_id
    AND  rma.remit_bank_acct_use_id = ba.bank_acct_use_id
    AND  ba.bank_account_id = cba.bank_account_id
    AND  ( cba.currency_code = p_currency_code
	    OR cba.receipt_multi_currency_flag = 'Y')
    AND  sysdate < nvl(ba.end_date, SYSDATE+1)
    AND  sysdate between rma.start_date and nvl(rma.end_date, SYSDATE)
    AND  sysdate between rm.start_date and NVL(rm.end_date, SYSDATE);

 -- verify that Bank Account payment method is set up in AR_SYSTEM_PARAMETERS

  SELECT count ( arm.receipt_method_id )
  INTO customer_bank_payment_method
  FROM    ar_receipt_methods         arm,
          ra_cust_receipt_methods    rcrm,
          ar_receipt_method_accounts arma,
          ce_bank_acct_uses_ou_v          aba,
          ce_bank_accounts           cba,
          ar_receipt_classes         arc
  WHERE   arm.receipt_method_id = rcrm.receipt_method_id
    AND       arm.receipt_method_id = arma.receipt_method_id
    AND       arm.receipt_class_id  = arc.receipt_class_id
    AND       rcrm.customer_id      = p_customer_id
    AND       arma.remit_bank_acct_use_id  = aba.bank_acct_use_id
    AND       aba.bank_account_id = cba.bank_account_id
    AND     ( NVL(rcrm.site_use_id,p_customer_site_id)  = p_customer_site_id
              OR
             (p_customer_site_id is null and rcrm.site_use_id is null)
            )
    AND   (
                 cba.currency_code    =  p_currency_code
                 OR
                 cba.receipt_multi_currency_flag = 'Y'
            )
   AND   (   arc.remit_flag = 'Y'
             and arc.confirm_flag = 'N'
	  )
   AND (
	  arc.creation_method_code = 'MANUAL'
	  or
   --Bug#6109909
          ( arm.payment_channel_code = 'BANK_ACCT_XFER'
	    and arc.creation_method_code = 'AUTOMATIC' )
	)
   -- AND       aba.set_of_books_id = arp_trx_global.system_info.system_parameters.set_of_books_id
   AND sysdate < NVL ( aba.end_date , sysdate+1)
   AND sysdate between arm.start_date AND NVL(arm.end_date, sysdate)
   AND sysdate between arma.start_date AND NVL(arma.end_date, sysdate) ;

  IF( (customer_bank_payment_method = 0) AND  (system_bank_payment_method = 0))
  THEN
    RETURN 0 ;
  ELSE
    RETURN 1 ;
  END IF;

EXCEPTION
WHEN OTHERS THEN
        l_debug_info := 'Unknown exception. Value in profile OIR_BA_PMT_METHOD=' ||  fnd_profile.VALUE('OIR_BA_PMT_METHOD');
        write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
       	write_debug_and_log('ERROR =>'|| SQLERRM);
        write_debug_and_log('-DEBUG_INFO-' || l_debug_info);
        RETURN 0;

END is_bank_acc_payment_enabled ;

/*============================================================
  | PUBLIC function save_payment_inst_info_wrapper
  |
  | DESCRIPTION
  |   This is a wrapper to return a VARCHAR2 instead of the Boolean returned
  |   by ARI_CONFIG.save_payment_instrument_info.
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 29-APR-2004   vnb          Created
  | 21-SEP-2004   vnb          Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.save_payment_instrument_info
  +============================================================*/
 FUNCTION save_payment_inst_info_wrapper ( p_customer_id          IN VARCHAR2,
                                           p_customer_site_use_id IN VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2 IS
 l_save_payment_inst_flag VARCHAR2(6);
 BEGIN
    -- Bug 3886652 - Customer Id and Customer Site Use Id added as params to ARI_CONFIG.save_payment_instrument_info
    if (ARI_UTILITIES.save_payment_instrument_info(p_customer_id, nvl(p_customer_site_use_id,-1))) then
        l_save_payment_inst_flag := 'true';
    else
        l_save_payment_inst_flag := 'false';
    end if;

    return l_save_payment_inst_flag;

 END save_payment_inst_info_wrapper;

 /*============================================================
  | PUBLIC function is_grace_days_enabled_wrapper
  |
  | DESCRIPTION
  |   This is a wrapper to return a VARCHAR2 instead of the Boolean returned
  |   by ARI_CONFIG.is_discount_grace_days_enabled.
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 28-APR-2004   vnb          Created
  +============================================================*/
 FUNCTION is_grace_days_enabled_wrapper RETURN VARCHAR2 IS
 l_grace_days_flag VARCHAR2(2);
 BEGIN
    if (ARI_UTILITIES.is_discount_grace_days_enabled) then
        l_grace_days_flag := 'Y';
    else
        l_grace_days_flag := 'N';
    end if;

    return l_grace_days_flag;

  END is_grace_days_enabled_wrapper;

/*============================================================
  | PUBLIC function get_discount_wrapper
  |
  | DESCRIPTION
  |   This is a function that is a wrapper to call the AR API for calculating
  |   discounts.
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 19-JUL-2004   vnb          Created
  +============================================================*/
FUNCTION get_discount_wrapper ( p_ps_id	  IN ar_payment_schedules.payment_schedule_id%TYPE,
                                 p_in_applied_amount IN NUMBER) RETURN NUMBER IS
    l_discount_amount NUMBER;
    l_customer_id     NUMBER;
    l_customer_site_use_id NUMBER;
    l_rem_amt_rcpt    NUMBER;
    l_rem_amt_inv     NUMBER;
    l_grace_days_flag VARCHAR2(2);
  BEGIN
    SELECT CUSTOMER_ID, CUSTOMER_SITE_USE_ID
    INTO  l_customer_id, l_customer_site_use_id
    FROM  ar_payment_schedules
    WHERE PAYMENT_SCHEDULE_ID = p_ps_id;

     -- Check if grace days have to be considered for discount.
     --l_grace_days_flag := is_grace_days_enabled_wrapper();
     l_grace_days_flag := ARI_UTILITIES.is_discount_grace_days_enabled(l_customer_id,l_customer_site_use_id);

     arp_discounts_api.get_discount(p_ps_id	            => p_ps_id,
		                           p_apply_date	        => trunc(sysdate),
                            	   p_in_applied_amount  => p_in_applied_amount,
		                           p_grace_days_flag    => l_grace_days_flag,
		                           p_out_discount       => l_discount_amount,
		                           p_out_rem_amt_rcpt 	=> l_rem_amt_rcpt,
		                           p_out_rem_amt_inv 	=> l_rem_amt_inv);

     return l_discount_amount;

  EXCEPTION
    when others then
        begin
            l_discount_amount := 0;
            write_debug_and_log('Unexpected Exception while calculating discount');
            write_debug_and_log('- Payment Schedule Id: '||p_ps_id);
            write_debug_and_log(SQLERRM);
            return l_discount_amount;
        end;
  END;

/*============================================================
  | PUBLIC function write_error_messages
  |
  | DESCRIPTION
  |   This is a procedure that reads and returns the error messages
  |   from the message stack.
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |
  | KNOWN ISSUES
  |
  |
  |
  | NOTES
  |
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 23-JUL-2004   vnb          Created
  +============================================================*/
  PROCEDURE write_error_messages (  p_msg_data IN OUT NOCOPY VARCHAR2,
                                    p_msg_count IN OUT NOCOPY NUMBER) IS

  l_msg_data VARCHAR2(2000);

  BEGIN
        p_msg_data := p_msg_data || '*';
        p_msg_count := 0;
        LOOP
            l_msg_data:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
            IF (l_msg_data IS NULL)THEN
                l_msg_data:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_TRUE);
                IF (l_msg_data IS NULL)THEN
                    EXIT;
                END IF;
                            END IF;
            p_msg_data := p_msg_data || l_msg_data || '*';
            p_msg_count := p_msg_count + 1;
	    write_debug_and_log(l_msg_data);
        END LOOP;
  END;

  /*=====================================================================
 | PROCEDURE reset_payment_amounts
 |
 | DESCRIPTION
 |   This function will reset the payment amounts on the Payment GT
 |   when the user clicks 'Reset to Defaults' button on Advanced Payment page
 |
 | PARAMETERS
 |   p_customer_id	   IN     NUMBER
 |   p_site_use_id     IN     NUMBER DEFAULT NULL
 |
 | HISTORY
 |   20-JAN-2005     vnb      Created
 |
 +=====================================================================*/
 PROCEDURE reset_payment_amounts (  p_customer_id		    IN NUMBER,
                                    p_site_use_id          IN NUMBER DEFAULT NULL,
                                    p_payment_type       IN varchar2 DEFAULT NULL,
                                    p_lookup_code       IN varchar2 DEFAULT NULL) IS
    l_total_service_charge     NUMBER;
    l_procedure_name           VARCHAR2(50);
    l_debug_info               VARCHAR2(200);

 BEGIN
    --Assign default values
    l_total_service_charge     := 0;
    l_procedure_name          := '.reset_payment_amounts';

    SAVEPOINT reset_payment_amounts_sp;
    -----------------------------------------------------------------------------------------
    l_debug_info := 'Update transaction list with original discount and payment amount';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
    END IF;
    --Striping by currency code is not required because
    --it is not possible to navigate to Payment page with multiple currencies
    --in the Transaction List for a cusomer context
    UPDATE AR_IREC_PAYMENT_LIST_GT
    SET discount_amount = original_discount_amt,
	    payment_amt = amount_due_remaining - original_discount_amt - nvl(dispute_amt,0)
    WHERE customer_id = p_customer_id
    AND   customer_site_use_id = nvl(decode(p_site_use_id, -1, null, p_site_use_id),customer_site_use_id);

    -----------------------------------------------------------------------------------------
    l_debug_info := 'Compute service charge';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
       arp_standard.debug(l_debug_info);
    END IF;
    l_total_service_charge := get_service_charge(p_customer_id, p_site_use_id, p_payment_type,p_lookup_code);

    COMMIT;

 EXCEPTION
    WHEN OTHERS THEN
        write_debug_and_log('Unexpected Exception while resetting payment and discount amounts');
        write_debug_and_log('- Customer Id: '||p_customer_id);
        write_debug_and_log('- Customer Site Id: '||p_site_use_id);
        write_debug_and_log('- Total Service charge: '||l_total_service_charge);
        write_debug_and_log(SQLERRM);

        ROLLBACK TO reset_payment_amounts_sp;

 END reset_payment_amounts;


/*=====================================================================
 | FUNCTION get_pymt_amnt_due_remaining
 |
 | DESCRIPTION
 |   This function will calculate the remianing amount for a
 |   payment that has been selected for apply credit andd return the
 |   total amount dure remaining that can be applied.
 |
 | HISTORY
 |
 +=====================================================================*/
 FUNCTION get_pymt_amnt_due_remaining (  p_cash_receipt_id    IN NUMBER) RETURN NUMBER IS

 l_amount_due_remaining NUMBER ;

 BEGIN
  select - sum(app.amount_applied) INTO l_amount_due_remaining
             	        from ar_receivable_applications app
	                    where nvl( app.confirmed_flag, 'Y' ) = 'Y'
                        AND app.status = 'UNAPP'
                        AND app.cash_receipt_id = p_cash_receipt_id;

   RETURN l_amount_due_remaining;

  END get_pymt_amnt_due_remaining;

/*============================================================
 | procedure update_cc_bill_to_site
 |
 | DESCRIPTION
 |   Creates/Updates Credit card bill to location with the given details
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date          Author       Description of Changes
 | 17-Aug-2005   rsinthre     Created
 +============================================================*/
  PROCEDURE update_cc_bill_to_site(
		p_cc_location_rec	IN   HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
		x_cc_bill_to_site_id	IN  NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_count		OUT NOCOPY NUMBER,
		x_msg_data		OUT NOCOPY VARCHAR2) IS

l_location_id			NUMBER(15,0);
l_location_rec			HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_party_site_rec		HZ_PARTY_SITE_V2PUB.party_site_rec_type;
l_party_site_number		VARCHAR2(30);
l_object_version_number		NUMBER(15,0);

CURSOR location_id_cur IS
	select hps.location_id, hl.object_version_number
	from hz_party_sites hps, hz_locations hl
	where party_site_id = x_cc_bill_to_site_id
	and hps.location_id = hl.location_id;

location_id_rec	location_id_cur%ROWTYPE;

l_procedure_name		VARCHAR2(30);
l_debug_info	 	        VARCHAR2(200);

BEGIN
	l_procedure_name  := '.update_cc_bill_to_site';
-----------------------------------------------------------------------------------------
  l_debug_info := 'Call TCA update location - update_location - to update location for CC';
-----------------------------------------------------------------------------------------
          write_debug_and_log('Site_id_to_update'|| x_cc_bill_to_site_id);

--Get LocationId from PartySiteId and update the location
		OPEN location_id_cur;
		FETCH location_id_cur INTO location_id_rec;
		IF(location_id_cur%FOUND) THEN
			l_location_id		:= location_id_rec.location_id;
			l_object_version_number	:= location_id_rec.object_version_number;
		ELSE
		   write_debug_and_log('No Location found for site:'||x_cc_bill_to_site_id );
		   x_return_status := FND_API.G_RET_STS_ERROR;
		   write_error_messages(x_msg_data, x_msg_count);
		   RETURN;
		END IF;
		CLOSE location_id_cur;

		write_debug_and_log('Loaction id to update:'|| l_location_id);

		l_location_rec.location_id	:= l_location_id;
		l_location_rec.country		:= p_cc_location_rec.country;
		l_location_rec.address1		:= p_cc_location_rec.address1;
		l_location_rec.address2		:= p_cc_location_rec.address2;
		l_location_rec.address3		:= p_cc_location_rec.address3;
		l_location_rec.city		:= p_cc_location_rec.city;
		l_location_rec.postal_code	:= p_cc_location_rec.postal_code;
		l_location_rec.state		:= p_cc_location_rec.state;
		l_location_rec.county		:= p_cc_location_rec.county;

		HZ_LOCATION_V2PUB.update_location(
		p_init_msg_list             => FND_API.G_TRUE,
		p_location_rec              => l_location_rec,
		p_object_version_number     => l_object_version_number,
		x_return_status             => x_return_status,
		x_msg_count                 => x_msg_count,
		x_msg_data                  => x_msg_data);

		IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	          x_return_status := FND_API.G_RET_STS_ERROR;
	          write_error_messages(x_msg_data, x_msg_count);
	          RETURN;
		END IF;

EXCEPTION
    WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;

            write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);

	    write_debug_and_log('l_location_id'|| l_location_id);
            write_debug_and_log('- Return Status: '||x_return_status);
            write_debug_and_log(SQLERRM);

            FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
            FND_MSG_PUB.ADD;

END update_cc_bill_to_site;

 /*=====================================================================
 | PROCEDURE get_payment_channel_attribs
 |
 | DESCRIPTION
 |   Gets payment channel attribute usages
 |
 | PARAMETERS
 |   p_channel_code	IN  	    VARCHAR2
 |   x_return_status 	OUT NOCOPY  VARCHAR2
 |   x_cvv_use 		OUT NOCOPY  VARCHAR2
 |   x_billing_addr_use	OUT NOCOPY  VARCHAR2
 |   x_msg_count        OUT NOCOPY  NUMBER
 |   x_msg_data         OUT NOCOPY  VARCHAR2
 |
 | HISTORY
 |   20-SEP-2006     abathini      Created
 |
 +=====================================================================*/
PROCEDURE get_payment_channel_attribs(	p_channel_code 		IN 	    VARCHAR2,
					x_return_status 	OUT NOCOPY  VARCHAR2,
					x_cvv_use 		OUT NOCOPY  VARCHAR2,
					x_billing_addr_use	OUT NOCOPY  VARCHAR2,
					x_msg_count           	OUT NOCOPY  NUMBER,
					x_msg_data            	OUT NOCOPY  VARCHAR2
				     )
IS
useRecType IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
resRecType IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_procedure_name		VARCHAR2(50);
l_debug_info	 	        VARCHAR2(200);
BEGIN

 l_procedure_name := '.get_payment_channel_attribs';
 -----------------------------------------------------------------------------------------
 l_debug_info := 'Call IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs - to get payment channel attribute usages';
 -----------------------------------------------------------------------------------------
    IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
    (
            p_api_version 		=> 1.0,
            x_return_status 	=> x_return_status,
            x_msg_count 		=> x_msg_count,
            x_msg_data 		=> x_msg_data,
            p_channel_code 		=> p_channel_code,
            x_channel_attrib_uses	=> useRecType,
            x_response 		=> resRecType
    );

    x_cvv_use := useRecType.Instr_SecCode_Use;
    x_billing_addr_use := useRecType.Instr_Billing_Address;

EXCEPTION
    WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;

            write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);

	    write_debug_and_log('p_channel_code'|| p_channel_code);
            write_debug_and_log('- Return Status: '||x_return_status);
            write_debug_and_log(SQLERRM);

            FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
            FND_MSG_PUB.ADD;
END get_payment_channel_attribs;

/*=====================================================================
 | PROCEDURE update_invoice_payment_status
 |
 | DESCRIPTION
 |   This procedure will update the PAYMENT_APPROVAL column in ar_payment_schedules
 |   with the value p_inv_pay_status for the records in p_payment_schedule_id_list
 |
 | PARAMETERS
 |   p_payment_schedule_id_list	   IN     Inv_list_table_type
 |   p_inv_pay_status     		   IN     VARCHAR2
 |
 | HISTORY
 |   17-FEB-2007     abathini      	   Created
 |
 +=====================================================================*/

PROCEDURE update_invoice_payment_status( p_payment_schedule_id_list	IN Inv_list_table_type,
                                 	     p_inv_pay_status			IN VARCHAR2,
                                 	     x_return_status			OUT  NOCOPY VARCHAR2,
				                 x_msg_count            		OUT  NOCOPY NUMBER,
				                 x_msg_data             		OUT  NOCOPY VARCHAR2
                                 ) IS

l_last_update_login		NUMBER(15);
l_last_update_date		DATE;
l_last_updated_by		NUMBER(15);

BEGIN

    l_last_update_login     := FND_GLOBAL.LOGIN_ID;
    l_last_update_date      := sysdate;
    l_last_updated_by       := FND_GLOBAL.USER_ID;

   FORALL trx
    IN p_payment_schedule_id_list.first .. p_payment_schedule_id_list.last
    UPDATE AR_PAYMENT_SCHEDULES set PAYMENT_APPROVAL =  p_inv_pay_status,
    LAST_UPDATE_DATE = l_last_update_date, LAST_UPDATED_BY = l_last_updated_by,
    LAST_UPDATE_LOGIN = l_last_update_login
    where payment_schedule_id = p_payment_schedule_id_list(trx);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_invoice_payment_status;

/*=====================================================================
 | FUNCTION get_customer_site_use_id
 |
 | DESCRIPTION
 | This function checks if the user has access to the primary bill to site
 | of the customer. If yes, then returns that site id.
 | else, checks if the transactions selected by the user belongs
 | to a same site. If yes, then return that site id else, returns -1.
 |
 | PARAMETERS
 |   p_session_id  IN   NUMBER
 |   p_customer_id IN   NUMBER
 |
 | RETURN
 |   l_customer_site_use_id  NUMBER
 | HISTORY
 |   29-Oct-2009     rsinthre              Created
 |
 +=====================================================================*/

 FUNCTION get_customer_site_use_id (p_session_id IN NUMBER,
                                    p_customer_id IN NUMBER
                                   )
				 RETURN NUMBER
 IS

 l_customer_site_use_id  NUMBER;
 l_debug_info		 VARCHAR2(200);
 l_procedure_name 	 VARCHAR2(30);

 e_no_rows_in_GT EXCEPTION;

 CURSOR get_cust_site_use_id_cur IS
	SELECT DISTINCT pay_for_customer_site_id
	FROM   ar_irec_payment_list_gt
	WHERE  customer_id = p_customer_id;

 BEGIN

  l_procedure_name := '.get_customer_site_use_id';
  l_customer_site_use_id := NULL;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name, 'Begin+');
	  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,
            'p_session_id=' || p_session_id ||
            'p_user_id=' || FND_GLOBAL.user_id ||
            'p_customer_id=' || p_customer_id);
  end if;


  ---------------------------------------------------------------------------
  l_debug_info := 'Check if the user has access to the primary bill to site id';
  ---------------------------------------------------------------------------
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	 fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,l_debug_info);
  end if;

  BEGIN

      SELECT  usite.customer_site_use_id
      INTO    l_customer_site_use_id
      FROM    ar_irec_user_acct_sites_all usite,
              hz_cust_site_uses hzcsite
      WHERE
      usite.session_id 	    =	p_session_id
      AND usite.customer_id	    =	p_customer_id
      AND usite.user_id 	    =	FND_GLOBAL.user_id
      AND hzcsite.site_use_id   =	usite.customer_site_use_id
      AND hzcsite.primary_flag  =	'Y'
      AND hzcsite.site_use_code =	'BILL_TO'
      AND hzcsite.status 	    =	'A' ;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	l_customer_site_use_id := NULL;
  END;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	 fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Check for acess to the Primary bill to site returned site id=' || l_customer_site_use_id);
  end if;

  IF (l_customer_site_use_id IS NULL) THEN
  /* So, user does not have access to primary bill to site
    Check, if the selected transactions belong to a same site. If yes, then return that site id else return -1.
  */
     OPEN get_cust_site_use_id_cur;
     LOOP
          FETCH get_cust_site_use_id_cur INTO l_customer_site_use_id ;

          IF get_cust_site_use_id_cur%ROWCOUNT >1 THEN
               if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'The selected transactions belong to more than one site');
               end if;
              l_customer_site_use_id := -1;
              EXIT;
          ELSIF get_cust_site_use_id_cur%ROWCOUNT = 0 THEN
               if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Query on ar_irec_payment_list_gt returned 0 rows');
               end if;
               RAISE e_no_rows_in_GT;
               EXIT;
          END IF;

          EXIT WHEN get_cust_site_use_id_cur%NOTFOUND OR get_cust_site_use_id_cur%NOTFOUND IS NULL;
     END LOOP;
     CLOSE get_cust_site_use_id_cur;

  END IF;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Return val: l_customer_site_use_id=' || l_customer_site_use_id);
  end if;

 RETURN l_customer_site_use_id;

 EXCEPTION
    WHEN e_no_rows_in_GT THEN
      write_debug_and_log('No rows present in ar_irec_payment_list_gt for the given customer in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('p_session_id: '|| p_session_id);
      write_debug_and_log('p_user_id: '|| FND_GLOBAL.user_id);
      write_debug_and_log('p_customer_id: '|| p_customer_id);

    WHEN OTHERS THEN
      write_debug_and_log('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
      write_debug_and_log('ERROR =>'|| SQLERRM);
      write_debug_and_log('p_session_id: '|| p_session_id);
      write_debug_and_log('p_user_id: '|| FND_GLOBAL.user_id);
      write_debug_and_log('p_customer_id: '|| p_customer_id);


 END get_customer_site_use_id;

END AR_IREC_PAYMENTS;

/
