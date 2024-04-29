--------------------------------------------------------
--  DDL for Package Body AR_IREC_APPLY_CREDITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_IREC_APPLY_CREDITS" AS
/* $Header: ARIAPCRB.pls 120.27 2007/11/28 14:22:51 rsinthre ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'AR_IREC_APPLY_CREDITS';
PG_DEBUG   VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PG_DIAGNOSTICS VARCHAR2(1) := NVL(FND_PROFILE.value('FND_DIAGNOSTICS'), 'N');

/*========================================================================
 | Prototype Declarations - Private Procedures
 *=======================================================================*/
PROCEDURE select_credit_to_apply( p_currency_code         IN VARCHAR2,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_credit_ps_id       OUT NOCOPY NUMBER,
                                  x_debit_ps_id        OUT NOCOPY NUMBER);

PROCEDURE apply_credits_on_payment(p_currency_code         IN VARCHAR2,
                                   x_open_invoices_status  OUT NOCOPY VARCHAR2,
                                   x_dup_appln_dbt_psid    OUT NOCOPY NUMBER,
                                   x_dup_appln_crdt_psid   OUT NOCOPY NUMBER,
                                   x_cash_receipt_id       OUT NOCOPY NUMBER,
                                   x_msg_count             OUT NOCOPY NUMBER,
                                   x_msg_data              OUT NOCOPY VARCHAR2,
                                   x_return_status         OUT NOCOPY VARCHAR2
                                 );

PROCEDURE apply_credits_on_credit_memo(p_currency_code         IN VARCHAR2,
                                       x_open_invoices_status  OUT NOCOPY VARCHAR2,
                                       x_dup_appln_dbt_psid    OUT NOCOPY NUMBER,
                                       x_dup_appln_crdt_psid   OUT NOCOPY NUMBER,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2,
                                       x_return_status         OUT NOCOPY VARCHAR2
                        );

/*============================================================
  | PUBLIC procedure copy_transaction_list_records
  |
  | DESCRIPTION
  |   Copy the transactions for the active customer, site and currency from the
  |   Transaction List GT to the Apply Credits GT
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
  | 12-OCT-2004   vnb          Created
  | 26-MAY-2005   rsinthre     Bug 4392371 - OIR needs to support cross customer payment
  +============================================================*/

PROCEDURE copy_transaction_list_records(p_customer_id           IN NUMBER,
                                        p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                                        p_currency_code         IN VARCHAR2
                                        ) IS

  CURSOR transaction_list (p_customer_id NUMBER,
                            p_customer_site_use_id NUMBER,
                            p_currency_code VARCHAR2) IS

  SELECT
        CUSTOMER_ID,
        CUSTOMER_SITE_USE_ID,
        ACCOUNT_NUMBER,
        CUSTOMER_TRX_ID,
        TRX_NUMBER,TRX_DATE,
        TRX_CLASS,
        DUE_DATE,
        PAYMENT_SCHEDULE_ID,
        STATUS,
        PAYMENT_TERMS,
        NUMBER_OF_INSTALLMENTS,
        TERMS_SEQUENCE_NUMBER,
        LINE_AMOUNT,
        TAX_AMOUNT ,
        FREIGHT_AMOUNT,
        FINANCE_CHARGES,
        CURRENCY_CODE ,
        AMOUNT_DUE_ORIGINAL,
        AMOUNT_DUE_REMAINING,
        PAYMENT_AMT ,
        SERVICE_CHARGE,
        DISCOUNT_AMOUNT,
        RECEIPT_DATE,
        RECEIPT_NUMBER,
        PO_NUMBER,
        SO_NUMBER,
        PRINTING_OPTION ,
        ATTRIBUTE_CATEGORY ,
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
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        CASH_RECEIPT_ID,
	PAY_FOR_CUSTOMER_ID,
	PAY_FOR_CUSTOMER_SITE_ID
   FROM ar_irec_payment_list_gt
   WHERE CUSTOMER_ID = p_customer_id
   AND CUSTOMER_SITE_USE_ID = nvl(p_customer_site_use_id,CUSTOMER_SITE_USE_ID)
   AND CURRENCY_CODE = p_currency_code;

   l_debit_transactions_flag  BOOLEAN;
   l_credit_transactions_flag BOOLEAN;

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN
    l_debit_transactions_flag  := false;
    l_credit_transactions_flag := false;

    l_procedure_name           := '.copy_transaction_list_records';


    ----------------------------------------------------------------------------------------
    l_debug_info := 'Fetch all transactions from Transaction List GT into Apply Credits GT';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    FOR trx IN transaction_list(p_customer_id,
                                p_customer_site_use_id,
                                p_currency_code )
    LOOP
        INSERT INTO ar_irec_apply_credit_gt
        (
            CUSTOMER_ID,
            CUSTOMER_SITE_USE_ID,
            ACCOUNT_NUMBER,
            CUSTOMER_TRX_ID,
            TRX_NUMBER,TRX_DATE,
            TRX_CLASS,
            DUE_DATE,
            PAYMENT_SCHEDULE_ID,
            STATUS,
            PAYMENT_TERMS,
            NUMBER_OF_INSTALLMENTS,
            TERMS_SEQUENCE_NUMBER,
            LINE_AMOUNT,
            TAX_AMOUNT ,
            FREIGHT_AMOUNT,
            FINANCE_CHARGES,
            CURRENCY_CODE ,
            AMOUNT_DUE_ORIGINAL,
            AMOUNT_DUE_REMAINING,
            PAYMENT_AMT ,
            SERVICE_CHARGE,
            DISCOUNT_AMOUNT,
            RECEIPT_DATE,
            RECEIPT_NUMBER,
            PO_NUMBER,
            SO_NUMBER,
            PRINTING_OPTION ,
            ATTRIBUTE_CATEGORY ,
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
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            APPLICATION_AMOUNT,
            CASH_RECEIPT_ID,
	    PAY_FOR_CUSTOMER_ID,
	    PAY_FOR_CUSTOMER_SITE_ID )
        VALUES
        (
		-- In create transaction list record of arirpmtb, the actual customer id of the transaction is stored in pay_for_customer_id
		-- and the customer id is the login customer id.
            trx.PAY_FOR_CUSTOMER_ID,
            trx.PAY_FOR_CUSTOMER_SITE_ID,
            trx.ACCOUNT_NUMBER,
            trx.CUSTOMER_TRX_ID,
            trx.TRX_NUMBER,
            trx.TRX_DATE,
            trx.TRX_CLASS,
            trx.DUE_DATE,
            trx.PAYMENT_SCHEDULE_ID,
            trx.STATUS,
            trx.PAYMENT_TERMS,
            trx.NUMBER_OF_INSTALLMENTS,
            trx.TERMS_SEQUENCE_NUMBER,
            trx.LINE_AMOUNT,
            trx.TAX_AMOUNT ,
            trx.FREIGHT_AMOUNT,
            trx.FINANCE_CHARGES,
            trx.CURRENCY_CODE ,
            trx.AMOUNT_DUE_ORIGINAL,
            trx.AMOUNT_DUE_REMAINING,
            trx.PAYMENT_AMT ,
            trx.SERVICE_CHARGE,
            trx.DISCOUNT_AMOUNT,
            trx.RECEIPT_DATE,
            trx.RECEIPT_NUMBER,
            trx.PO_NUMBER,
            trx.SO_NUMBER,
            trx.PRINTING_OPTION ,
            trx.ATTRIBUTE_CATEGORY ,
            trx.ATTRIBUTE1,
            trx.ATTRIBUTE2,
            trx.ATTRIBUTE3,
            trx.ATTRIBUTE4,
            trx.ATTRIBUTE5,
            trx.ATTRIBUTE6,
            trx.ATTRIBUTE7,
            trx.ATTRIBUTE8,
            trx.ATTRIBUTE9,
            trx.ATTRIBUTE10,
            trx.ATTRIBUTE11,
            trx.ATTRIBUTE12,
            trx.ATTRIBUTE13,
            trx.ATTRIBUTE14,
            trx.ATTRIBUTE15,
            trx.INTERFACE_HEADER_CONTEXT,
            trx.INTERFACE_HEADER_ATTRIBUTE1,
            trx.INTERFACE_HEADER_ATTRIBUTE2,
            trx.INTERFACE_HEADER_ATTRIBUTE3,
            trx.INTERFACE_HEADER_ATTRIBUTE4,
            trx.INTERFACE_HEADER_ATTRIBUTE5,
            trx.INTERFACE_HEADER_ATTRIBUTE6,
            trx.INTERFACE_HEADER_ATTRIBUTE7,
            trx.INTERFACE_HEADER_ATTRIBUTE8,
            trx.INTERFACE_HEADER_ATTRIBUTE9,
            trx.INTERFACE_HEADER_ATTRIBUTE10,
            trx.INTERFACE_HEADER_ATTRIBUTE11,
            trx.INTERFACE_HEADER_ATTRIBUTE12,
            trx.INTERFACE_HEADER_ATTRIBUTE13,
            trx.INTERFACE_HEADER_ATTRIBUTE14,
            trx.INTERFACE_HEADER_ATTRIBUTE15,
            trx.LAST_UPDATE_DATE,
            trx.LAST_UPDATED_BY,
            trx.CREATION_DATE,
            trx.CREATED_BY,
            trx.LAST_UPDATE_LOGIN,
            trx.PAYMENT_AMT,
            trx.CASH_RECEIPT_ID,
	    trx.PAY_FOR_CUSTOMER_ID,
	    trx.PAY_FOR_CUSTOMER_SITE_ID
        );

    END LOOP;

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

END copy_transaction_list_records;


/*============================================================
  | PUBLIC procedure copy_open_debits
  |
  | DESCRIPTION
  |   Copy all open debit transactions for the active customer, site and currency from the
  |   AR_PAYMENT_SCHEDULES to the Apply Credits GT
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
  | 12-OCT-2004   vnb          Created
  | 26-MAY-2005   rsinthre     Bug 4392371 - OIR needs to support cross customer payment
  +============================================================*/

PROCEDURE copy_open_debits(p_customer_id           IN NUMBER,
                           p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                           p_currency_code         IN VARCHAR2
                           ) IS
BEGIN
		--This procedure is no longer used, so removed the code from this procedure.
		NULL;
END copy_open_debits;

/*============================================================
  | PUBLIC procedure copy_open_credits
  |
  | DESCRIPTION
  |   Copy all open credit transactions for the active customer, site and currency from the
  |   AR_PAYMENT_SCHEDULES to the Apply Credits GT
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
  | 12-OCT-2004   vnb          Created
  | 26-MAY-2005   rsinthre     Bug 4392371 - OIR needs to support cross customer payment
  +============================================================*/

PROCEDURE copy_open_credits(p_customer_id           IN NUMBER,
                            p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                            p_currency_code         IN VARCHAR2
                           ) IS
BEGIN
	--This procedure is no longer used, so removed the code from this procedure.
	NULL;
END copy_open_credits;

/*============================================================
  | PUBLIC procedure create_apply_credits_record
  |
  | DESCRIPTION
  |   Copy the transactions for the active customer, site and currency from the
  |   Transaction List GT to the Apply Credits GT
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_payment_schedule_id       IN NUMBER
  |   p_customer_id		  IN NUMBER
  |   p_customer_site_id	  IN NUMBER
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
  | 12-OCT-2004   vnb          Created
  | 26-MAY-2005   rsinthre     Bug 4392371 - OIR needs to support cross customer payment
  +============================================================*/
PROCEDURE create_apply_credits_record( p_payment_schedule_id   IN NUMBER,
				       p_customer_id IN NUMBER,
				       p_customer_site_id IN NUMBER
                                      ) IS

   l_trx_class                VARCHAR2(20);
   l_amount_due_remaining     NUMBER;
   l_customer_id              NUMBER;
   l_customer_site_use_id     NUMBER;
   l_currency_code            VARCHAR2(15);
   l_cash_receipt_id          NUMBER;

   l_discount_amount          NUMBER;
   l_rem_amt_rcpt             NUMBER;
   l_rem_amt_inv              NUMBER;
   l_grace_days_flag          VARCHAR2(2);

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);
   l_pay_for_cust_id	     NUMBER(15);
   l_pay_for_cust_site_id      NUMBER(15);

BEGIN

    l_procedure_name           := '.create_apply_credits_record';
    l_discount_amount          := 0;
    l_rem_amt_rcpt             := 0;
    l_rem_amt_inv              := 0;


    select class, amount_due_remaining, cash_receipt_id, ct.PAYING_CUSTOMER_ID, ct.PAYING_SITE_USE_ID, ps.CUSTOMER_ID, ps.CUSTOMER_SITE_USE_ID
    into l_trx_class, l_amount_due_remaining, l_cash_receipt_id, l_pay_for_cust_id, l_pay_for_cust_site_id, l_customer_id, l_customer_site_use_id
    from ar_payment_schedules ps, ra_customer_trx ct
    where ps.CUSTOMER_TRX_ID = ct.CUSTOMER_TRX_ID(+)
    and ps.payment_schedule_id = p_payment_schedule_id;

    --Bug 4000279 - Modified to check for 'UNAPP' status only
    IF (l_trx_class = 'PMT') THEN
         select -sum(app.amount_applied)
         into  l_amount_due_remaining
 	     from ar_receivable_applications app
	     where nvl( app.confirmed_flag, 'Y' ) = 'Y'
         AND app.status = 'UNAPP'
         AND app.cash_receipt_id = l_cash_receipt_id;

    ELSIF (l_trx_class = 'INV') THEN

        l_grace_days_flag := AR_IREC_PAYMENTS.is_grace_days_enabled_wrapper();

        arp_discounts_api.get_discount(p_ps_id	            => p_payment_schedule_id,
		                               p_apply_date	        => sysdate,
                            	       p_in_applied_amount  => l_amount_due_remaining,
		                               p_grace_days_flag    => l_grace_days_flag,
		                               p_out_discount       => l_discount_amount,
		                               p_out_rem_amt_rcpt 	=> l_rem_amt_rcpt,
		                               p_out_rem_amt_inv 	=> l_rem_amt_inv);
    END IF;

    ----------------------------------------------------------------------------------------
    l_debug_info := 'Populate the Apply Credits GT with the transaction';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    if(l_pay_for_cust_id is null) then
       l_pay_for_cust_id        := l_customer_id;
       l_pay_for_cust_site_id   := l_customer_site_use_id;
    end if;

    INSERT INTO ar_irec_apply_credit_gt
        (
            CUSTOMER_ID,
            CUSTOMER_SITE_USE_ID,
            ACCOUNT_NUMBER,
            CUSTOMER_TRX_ID,
            TRX_NUMBER,TRX_DATE,
            TRX_CLASS,
            DUE_DATE,
            PAYMENT_SCHEDULE_ID,
            STATUS,
            PAYMENT_TERMS,
            NUMBER_OF_INSTALLMENTS,
            TERMS_SEQUENCE_NUMBER,
            LINE_AMOUNT,
            TAX_AMOUNT ,
            FREIGHT_AMOUNT,
            FINANCE_CHARGES,
            CURRENCY_CODE ,
            AMOUNT_DUE_ORIGINAL,
            AMOUNT_DUE_REMAINING,
            PAYMENT_AMT ,
            SERVICE_CHARGE,
            DISCOUNT_AMOUNT,
            RECEIPT_DATE,
            PO_NUMBER,
            SO_NUMBER,
            PRINTING_OPTION ,
            ATTRIBUTE_CATEGORY ,
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
            APPLICATION_AMOUNT,
            CASH_RECEIPT_ID,
	    PAY_FOR_CUSTOMER_ID,
	    PAY_FOR_CUSTOMER_SITE_ID)
            SELECT l_customer_id,
                DECODE(l_customer_site_use_id,to_number(''),-1,l_customer_site_use_id),
               hca.account_number,
               ps.customer_trx_id,
               ps.trx_number,
               ps.trx_date,
               ps.class,
               ps.due_date,
               ps.payment_schedule_id,
               ps.status,
               rt.name,
               ARPT_SQL_FUNC_UTIL.Get_Number_Of_Due_Dates(ps.term_id) number_of_installments,
               ps.terms_sequence_number,
               ps.amount_line_items_original line_amount,
               ps.tax_original tax_amount,
               ps.freight_original freight_amount,
               ps.receivables_charges_charged finance_charge,
               ps.INVOICE_CURRENCY_CODE,
               ps.AMOUNT_DUE_ORIGINAL,
               l_amount_due_remaining,
               NULL,
               0,
               l_discount_amount,
               sysdate,
               ct.PURCHASE_ORDER,
               NULL,
               ct.printing_option,
               ps.ATTRIBUTE_CATEGORY ,
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
              ARI_UTILITIES.curr_round_amt(l_amount_due_remaining - l_discount_amount,ps.INVOICE_CURRENCY_CODE),
              l_cash_receipt_id,
	      l_pay_for_cust_id,
	      --Bug 4062938 - Handling of transactions with no site id
              decode(l_pay_for_cust_site_id, null, -1,l_pay_for_cust_site_id) as customer_site_use_id
        FROM ar_payment_schedules ps, hz_cust_accounts hca, ra_terms rt, ra_customer_trx ct
        WHERE ps.payment_schedule_id = p_payment_schedule_id
        AND   ps.customer_id         = hca.cust_account_id
        AND   ps.term_id             = rt.term_id(+)
        AND   ps.customer_trx_id     = ct.customer_trx_id(+);

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Payment Schedule Id: '||p_payment_schedule_id);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END create_apply_credits_record;

/*============================================================
  | PUBLIC procedure delete_all_debits
  |
  | DESCRIPTION
  |   Deletes all credit transactions for the active customer, site and currency from the
  |   Apply Credits GT
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
  | 13-OCT-2004   vnb          Created
  +============================================================*/

PROCEDURE delete_all_debits(p_customer_id           IN NUMBER,
                            p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                            p_currency_code         IN VARCHAR2
                            ) IS

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN
    l_procedure_name           := '.delete_all_debits';


    ---------------------------------------------------------------------------
    l_debug_info := 'Delete all debit transactions from Apply Credits GT';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    DELETE FROM ar_irec_apply_credit_gt
    WHERE  customer_id          = p_customer_id
    AND    customer_site_use_id = nvl(p_customer_site_use_id, customer_site_use_id)
    AND    currency_code        = p_currency_code
    AND    ( trx_class          = 'INV' OR
             trx_class          = 'DM' OR
             trx_class          = 'CB' OR
             trx_class          = 'DEP'
	       );

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

END delete_all_debits;

/*============================================================
  | PUBLIC procedure delete_all_credits
  |
  | DESCRIPTION
  |   Deletes all credit transactions for the active customer, site and currency from the
  |   Apply Credits GT
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
  | 13-OCT-2004   vnb          Created
  +============================================================*/

PROCEDURE delete_all_credits(p_customer_id           IN NUMBER,
                             p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                             p_currency_code         IN VARCHAR2
                            ) IS
   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN

    l_procedure_name           := '.delete_all_credits';


    ---------------------------------------------------------------------------
    l_debug_info := 'Delete all credit transactions from Apply Credits GT';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    DELETE FROM ar_irec_apply_credit_gt
    WHERE  customer_id          = p_customer_id
    AND    customer_site_use_id = nvl(p_customer_site_use_id, customer_site_use_id)
    AND    currency_code        = p_currency_code
    AND    ( trx_class          = 'CM' OR
             trx_class          = 'PMT'
	       );

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

END delete_all_credits;

/*============================================================
  | PUBLIC procedure delete_apply_credits_record
  |
  | DESCRIPTION
  |   Deletes a transaction, specified by a Payment Schedule Id, from the Apply Credits GT
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_payment_schedule_id       IN NUMBER
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
  | 13-OCT-2004   vnb          Created
  +============================================================*/

PROCEDURE delete_apply_credits_record( p_payment_schedule_id   IN NUMBER
                                      ) IS

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN
    l_procedure_name           := '.delete_apply_credits_record';


    ---------------------------------------------------------------------------
    l_debug_info := 'Delete the transaction from Apply Credits GT';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    DELETE FROM ar_irec_apply_credit_gt
    WHERE  payment_schedule_id = p_payment_schedule_id;

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Payment Schedule Id: '||p_payment_schedule_id);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;

END delete_apply_credits_record;

/*============================================================
  | PUBLIC procedure delete_all_records
  |
  | DESCRIPTION
  |   Deletes all transactions for the active customer, site and currency from the
  |   Apply Credits GT
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
  | 13-OCT-2004   vnb          Created
  +============================================================*/

PROCEDURE delete_all_records(p_customer_id           IN NUMBER,
                             p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                             p_currency_code         IN VARCHAR2
                            ) IS
   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN

    l_procedure_name           := '.delete_all_records';


    ---------------------------------------------------------------------------
    l_debug_info := 'Delete all transactions from Apply Credits GT';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;
    -- Bug 5076215 - Apply Credits GT contains data related to the customer and its related customer,
    -- the related customer transactions are not getting cleared. Since GT contains only session specific data removed the where condition.
    DELETE FROM ar_irec_apply_credit_gt;
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

END delete_all_records;

/*============================================================
  | PUBLIC procedure apply_credits
  |
  | DESCRIPTION
  |   Applies selected credits against selected debits
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_customer_id               IN NUMBER
  |   p_customer_site_use_id      IN NUMBER DEFAULT NULL
  |   p_currency_code             IN VARCHAR2
  |   p_credit_memos_only         IN VARCHAR2
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
  | 13-OCT-2004   vnb          Created
  | 06-DEC-2004   vnb          Bug 4042557 - Change sign in credit application amount
  | 10-JAN-2005   vnb          Bug 4105891 - Check if invoice will remain open after application
  | 12-Jan-2005   vnb          Bug 4050280 - Added 'ORDER BY' clause in cursors for applying credits
  | 25-Jan-2005   vnb          Bug 4103527 - Display error icons for duplicate application
  +============================================================*/

PROCEDURE apply_credits(p_customer_id           IN NUMBER,
                        p_customer_site_use_id  IN NUMBER DEFAULT NULL,
			      p_driving_customer_id   IN NUMBER,
                        p_currency_code         IN VARCHAR2,
                        p_credit_memos_only     IN VARCHAR2,
                        x_open_invoices_status  OUT NOCOPY VARCHAR2,
                        x_dup_appln_dbt_psid    OUT NOCOPY NUMBER,
                        x_dup_appln_crdt_psid   OUT NOCOPY NUMBER,
                        x_cash_receipt_id       OUT NOCOPY NUMBER,
                        x_msg_count             OUT NOCOPY NUMBER,
                        x_msg_data              OUT NOCOPY VARCHAR2,
                        x_return_status         OUT NOCOPY VARCHAR2
                        ) IS

    l_procedure_name          VARCHAR2(50);
    l_debug_info	 	      VARCHAR2(200);
    l_customer_id             NUMBER;
    l_customer_site_use_id    NUMBER;

BEGIN

    l_procedure_name    := '.apply_credits';
    x_cash_receipt_id   := 0;

    DELETE FROM ar_irec_apply_credit_gt WHERE PRINTING_OPTION <> 'Y';
    COMMIT;

    if(p_driving_customer_id is NOT NULL and p_driving_customer_id <> p_customer_id) then
        l_customer_id := p_driving_customer_id;
        l_customer_site_use_id := NULL;
    end if;

    IF (p_credit_memos_only = 'Y') THEN
        ---------------------------------------------------------------------------
        l_debug_info := 'Apply credits on credit memo';
        ---------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug(l_debug_info);
        END IF;
        apply_credits_on_credit_memo(p_currency_code,
                                     x_open_invoices_status,
                                     x_dup_appln_dbt_psid,
                                     x_dup_appln_crdt_psid,
                                     x_msg_count,
                                     x_msg_data,
                                     x_return_status
                                    );
    ELSE
        ---------------------------------------------------------------------------
        l_debug_info := 'Apply credits on payment';
        ---------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug(l_debug_info);
        END IF;
        apply_credits_on_payment(    p_currency_code,
                                     x_open_invoices_status,
                                     x_dup_appln_dbt_psid,
                                     x_dup_appln_crdt_psid,
                                     x_cash_receipt_id,
                                     x_msg_count,
                                     x_msg_data,
                                     x_return_status
                                    );
    END IF;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        AR_IREC_PAYMENTS.write_error_messages(x_msg_data,x_msg_count);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Customer Id: '||p_customer_id);
        arp_standard.debug('- Customer Site Use Id: '||p_customer_site_use_id);
        arp_standard.debug('- Currency Code: '||p_currency_code);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

     IF(PG_DIAGNOSTICS = 'Y') THEN
        FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
        FND_MSG_PUB.ADD;
      ELSE
        x_msg_data := x_msg_data||SQLERRM;
      END IF;

      AR_IREC_PAYMENTS.write_error_messages(x_msg_data,x_msg_count);

END apply_credits;


/*============================================================
  | PRIVATE procedure apply_credits_on_payment
  |
  | DESCRIPTION
  |   Applies selected credits and selected debits against a selected payment
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
  | 02-FEB-2005   vnb          Created
  +============================================================*/

PROCEDURE apply_credits_on_payment(p_currency_code         IN VARCHAR2,
                                   x_open_invoices_status  OUT NOCOPY VARCHAR2,
                                   x_dup_appln_dbt_psid    OUT NOCOPY NUMBER,
                                   x_dup_appln_crdt_psid   OUT NOCOPY NUMBER,
                                   x_cash_receipt_id       OUT NOCOPY NUMBER,
                                   x_msg_count             OUT NOCOPY NUMBER,
                                   x_msg_data              OUT NOCOPY VARCHAR2,
                                   x_return_status         OUT NOCOPY VARCHAR2
                        ) IS

   CURSOR debit_transactions(p_currency_code VARCHAR2) IS
   SELECT   CUSTOMER_ID,
            CUSTOMER_SITE_USE_ID,
            CUSTOMER_TRX_ID,
            TRX_NUMBER,
            TRX_DATE,
            TRX_CLASS,
            DUE_DATE,
            PAYMENT_SCHEDULE_ID,
            STATUS,
            TERMS_SEQUENCE_NUMBER,
            LINE_AMOUNT,
            TAX_AMOUNT ,
            FREIGHT_AMOUNT,
            FINANCE_CHARGES,
            CURRENCY_CODE ,
            AMOUNT_DUE_ORIGINAL,
            AMOUNT_DUE_REMAINING,
            SERVICE_CHARGE,
            DISCOUNT_AMOUNT,
            APPLICATION_AMOUNT,
            CASH_RECEIPT_ID
   FROM     ar_irec_apply_credit_gt
   WHERE    CURRENCY_CODE        = p_currency_code
   AND      ( TRX_CLASS = 'INV' OR
              TRX_CLASS = 'DM' OR
              TRX_CLASS = 'CB' OR
              TRX_CLASS = 'DEP'
	        )
   ORDER BY AMOUNT_DUE_REMAINING ASC;

   CURSOR credit_transactions(p_currency_code VARCHAR2) IS
   SELECT   CUSTOMER_ID,
            CUSTOMER_SITE_USE_ID,
            CUSTOMER_TRX_ID,
            TRX_NUMBER,
            TRX_DATE,
            TRX_CLASS,
            DUE_DATE,
            PAYMENT_SCHEDULE_ID,
            STATUS,
            TERMS_SEQUENCE_NUMBER,
            LINE_AMOUNT,
            TAX_AMOUNT ,
            FREIGHT_AMOUNT,
            FINANCE_CHARGES,
            CURRENCY_CODE ,
            AMOUNT_DUE_ORIGINAL,
            AMOUNT_DUE_REMAINING,
            SERVICE_CHARGE,
            DISCOUNT_AMOUNT,
            APPLICATION_AMOUNT,
            CASH_RECEIPT_ID
   FROM     ar_irec_apply_credit_gt
   WHERE    CURRENCY_CODE        = p_currency_code
   AND      ( TRX_CLASS = 'CM' OR
              TRX_CLASS = 'PMT'
	        )
   ORDER BY PAYMENT_SCHEDULE_ID;

   CURSOR find_cash_receipt(p_ps_id NUMBER) IS
        select cash_receipt_id
        from ar_payment_schedules
        where payment_schedule_id = p_ps_id;

   debit_trx_record           debit_transactions%ROWTYPE;
   credit_trx_record          credit_transactions%ROWTYPE;
   find_cash_receipt_record   find_cash_receipt%ROWTYPE;

   l_return_status           VARCHAR2(10);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(255);

   l_sel_cash_receipt_id     NUMBER;

   l_application_ref_num        ar_receivable_applications.application_ref_num%TYPE;
   l_receivable_application_id  ar_receivable_applications.receivable_application_id%TYPE;
   l_applied_rec_app_id         ar_receivable_applications.receivable_application_id%TYPE;
   l_acctd_amount_applied_from  ar_receivable_applications.acctd_amount_applied_from%TYPE;
   l_acctd_amount_applied_to    ar_receivable_applications.acctd_amount_applied_to%TYPE;

   l_procedure_name          VARCHAR2(50);
   l_debug_info	 	         VARCHAR2(200);

BEGIN
    x_msg_count                := 0;
    x_msg_data                 := '*';
    x_open_invoices_status     := 'N';
    l_sel_cash_receipt_id      := 0;
    x_return_status            := FND_API.G_RET_STS_ERROR;

    l_procedure_name           := '.apply_credits_on_payment';

    SAVEPOINT ARI_APPLY_CREDITS_PMT;


    --------------------------------------------------------------------------------
    l_debug_info := 'Get the credit transaction to apply other transactions against';
    --------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;
    select_credit_to_apply( p_currency_code        => p_currency_code,
                            x_return_status        => x_return_status,
                            x_credit_ps_id         => x_dup_appln_crdt_psid,
                            x_debit_ps_id          => x_dup_appln_dbt_psid
                           );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (x_dup_appln_crdt_psid = 0) THEN
            ---------------------------------------------------------------------------
            l_debug_info := 'An unexpected error has occurred while finding the credit';
            ---------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;
            APP_EXCEPTION.raise_exception;
        ELSE
            ---------------------------------------------------------------------------
            l_debug_info := 'Duplicate application error';
            ---------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;

            ROLLBACK TO ARI_APPLY_CREDITS_PMT;

            FND_MESSAGE.SET_NAME('AR', 'AR_RW_PAID_INVOICE_TWICE' );
            FND_MSG_PUB.ADD;

            x_cash_receipt_id := l_sel_cash_receipt_id;

            RETURN;
        END IF;
    END IF;

    --Get the cash_receipt_id if selected credit is a payment
        ---------------------------------------------------------------------------
        l_debug_info := 'Find cash receipt id';
        ---------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug(l_debug_info);
        END IF;
        OPEN find_cash_receipt(x_dup_appln_crdt_psid);
        FETCH find_cash_receipt INTO find_cash_receipt_record;
        IF (find_cash_receipt%FOUND) THEN
            l_sel_cash_receipt_id := find_cash_receipt_record.cash_receipt_id;
        ELSE
            --Should not come here
            APP_EXCEPTION.raise_exception;
        END IF;
        CLOSE find_cash_receipt;

        x_cash_receipt_id := l_sel_cash_receipt_id;

    ----------------------------------------------------------------------------------
    l_debug_info := 'Apply credits against the selected payment';
    ----------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    FOR credit_trx_record in credit_transactions(p_currency_code)
    LOOP
        --If this is the credit transaction selected to be applied against, do not do anything.
        IF (credit_trx_record.payment_schedule_id <> x_dup_appln_crdt_psid) THEN

            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug('-------Credit Transaction Information------');
                arp_standard.debug('Customer Id: ' || credit_trx_record.customer_id);
                arp_standard.debug('Customer Site Use Id: ' || credit_trx_record.customer_site_use_id);
                arp_standard.debug('Customer Trx Id: ' || credit_trx_record.customer_trx_id);
                arp_standard.debug('Trx Number: ' || credit_trx_record.trx_number);
                arp_standard.debug('Trx Date: ' || credit_trx_record.trx_date);
                arp_standard.debug('Trx Class: ' || credit_trx_record.trx_class);
                arp_standard.debug('Due Date: ' || credit_trx_record.due_date);
                arp_standard.debug('Payment Schedule Id: ' || credit_trx_record.payment_schedule_id);
                arp_standard.debug('Status: ' || credit_trx_record.status);
                arp_standard.debug('Terms Sequence Number: ' || credit_trx_record.terms_sequence_number);
                arp_standard.debug('Line Amount: ' || credit_trx_record.line_amount);
                arp_standard.debug('Tax Amount: ' || credit_trx_record.tax_amount);
                arp_standard.debug('Freight Amount: ' || credit_trx_record.freight_amount);
                arp_standard.debug('Finance Charges: ' || credit_trx_record.trx_class);
                arp_standard.debug('Currency Code: ' || credit_trx_record.currency_code);
                arp_standard.debug('Amount Due Original: ' || credit_trx_record.amount_due_original);
                arp_standard.debug('Amount Due Remaining: ' || credit_trx_record.amount_due_remaining);
                arp_standard.debug('Discount Amount: ' || credit_trx_record.discount_amount);
                arp_standard.debug('Application Amount: ' || credit_trx_record.application_amount);
                arp_standard.debug('Cash Receipt Id: ' || credit_trx_record.cash_receipt_id);
            END IF;

            IF (credit_trx_record.trx_class = 'CM') THEN
                ----------------------------------------------------------------------------------
                l_debug_info := 'Apply credit memo against selected payment';
                ----------------------------------------------------------------------------------
                IF (PG_DEBUG = 'Y') THEN
                    arp_standard.debug(l_debug_info);
                END IF;

                AR_RECEIPT_API_PUB.apply(
                            p_api_version           => 1.0,
                            p_init_msg_list         => FND_API.G_TRUE,
                            p_commit                => FND_API.G_FALSE,
                            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status         => l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data,
                            p_cash_receipt_id       => l_sel_cash_receipt_id,
                            p_customer_trx_id       => credit_trx_record.customer_trx_id,
                            p_installment           => credit_trx_record.terms_sequence_number,
                            p_applied_payment_schedule_id => credit_trx_record.payment_schedule_id,
                            p_amount_applied        => credit_trx_record.application_amount,
                            p_discount              => credit_trx_record.discount_amount,
                            p_called_from           => 'IREC'
                            );

            ELSIF (credit_trx_record.trx_class = 'PMT') THEN
                ----------------------------------------------------------------------------------
                l_debug_info := 'Apply payment against selected payment';
                ----------------------------------------------------------------------------------
                IF (PG_DEBUG = 'Y') THEN
                    arp_standard.debug(l_debug_info);
                END IF;

                AR_RECEIPT_API_PUB.apply_open_receipt
                            (p_api_version                 => 1.0,
                             p_init_msg_list               => FND_API.G_TRUE,
                             p_commit                      => FND_API.G_FALSE,
                             x_return_status               => l_return_status,
                             x_msg_count                   => l_msg_count,
                             x_msg_data                    => l_msg_data,
                             p_cash_receipt_id             => l_sel_cash_receipt_id,
                             p_open_cash_receipt_id        => credit_trx_record.cash_receipt_id,
                             p_amount_applied              => credit_trx_record.application_amount,
                             p_called_from                 => 'IREC',
                             x_application_ref_num         => l_application_ref_num,
                             x_receivable_application_id   => l_receivable_application_id,
                             x_applied_rec_app_id          => l_applied_rec_app_id,
                             x_acctd_amount_applied_from   => l_acctd_amount_applied_from,
                             x_acctd_amount_applied_to     => l_acctd_amount_applied_to
                             );

            END IF;

            --Check for errors
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status   := FND_API.G_RET_STS_ERROR;
                x_msg_data        := x_msg_data || l_msg_data;
                x_msg_count       := x_msg_count + l_msg_count;

                ROLLBACK TO ARI_APPLY_CREDITS_PMT;

                RETURN;
            END IF;

        END IF;

    END LOOP;

    ----------------------------------------------------------------------------------
    l_debug_info := 'Apply invoices against the selected payment';
    ----------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    FOR debit_trx_record in debit_transactions(p_currency_code)
    LOOP
          IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug('-------Debit Transaction Information------');
            arp_standard.debug('Customer Id: ' || debit_trx_record.customer_id);
            arp_standard.debug('Customer Site Use Id: ' || debit_trx_record.customer_site_use_id);
            arp_standard.debug('Customer Trx Id: ' || debit_trx_record.customer_trx_id);
            arp_standard.debug('Trx Number: ' || debit_trx_record.trx_number);
            arp_standard.debug('Trx Date: ' || debit_trx_record.trx_date);
            arp_standard.debug('Trx Class: ' || debit_trx_record.trx_class);
            arp_standard.debug('Due Date: ' || debit_trx_record.due_date);
            arp_standard.debug('Payment Schedule Id: ' || debit_trx_record.payment_schedule_id);
            arp_standard.debug('Status: ' || debit_trx_record.status);
            arp_standard.debug('Terms Sequence Number: ' || debit_trx_record.terms_sequence_number);
            arp_standard.debug('Line Amount: ' || debit_trx_record.line_amount);
            arp_standard.debug('Tax Amount: ' || debit_trx_record.tax_amount);
            arp_standard.debug('Freight Amount: ' || debit_trx_record.freight_amount);
            arp_standard.debug('Finance Charges: ' || debit_trx_record.trx_class);
            arp_standard.debug('Currency Code: ' || debit_trx_record.currency_code);
            arp_standard.debug('Amount Due Original: ' || debit_trx_record.amount_due_original);
            arp_standard.debug('Amount Due Remaining: ' || debit_trx_record.amount_due_remaining);
            arp_standard.debug('Discount Amount: ' || debit_trx_record.discount_amount);
            arp_standard.debug('Application Amount: ' || debit_trx_record.application_amount);
            arp_standard.debug('Cash Receipt Id: ' || debit_trx_record.cash_receipt_id);
         END IF;

         IF (x_open_invoices_status = 'N') THEN
            ----------------------------------------------------------------------------------
            l_debug_info := 'Check if invoice will remain open after the application';
            ----------------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;

            IF (debit_trx_record.amount_due_remaining
                     - ( debit_trx_record.discount_amount + debit_trx_record.application_amount) > 0) THEN
                    x_open_invoices_status := 'Y';
            END IF;
         END IF;

         ----------------------------------------------------------------------------------
         l_debug_info := 'Apply invoice against selected payment';
         ----------------------------------------------------------------------------------
         IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug(l_debug_info);
         END IF;

         AR_RECEIPT_API_PUB.apply(
                            p_api_version           => 1.0,
                            p_init_msg_list         => FND_API.G_TRUE,
                            p_commit                => FND_API.G_FALSE,
                            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status         => l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data,
                            p_cash_receipt_id       => l_sel_cash_receipt_id,
                            p_customer_trx_id       => debit_trx_record.customer_trx_id,
                            p_installment           => debit_trx_record.terms_sequence_number,
                            p_applied_payment_schedule_id => debit_trx_record.payment_schedule_id,
                            p_amount_applied        => debit_trx_record.application_amount,
                            p_discount              => debit_trx_record.discount_amount,
                            p_called_from           => 'IREC'
                            );

          --Check for errors
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status   := FND_API.G_RET_STS_ERROR;
                x_msg_data        := x_msg_data || l_msg_data;
                x_msg_count       := x_msg_count + l_msg_count;

                ROLLBACK TO ARI_APPLY_CREDITS_PMT;

                RETURN;
            END IF;

    END LOOP;
    ---------------------------------------------------------------------------
    l_debug_info := 'Close the credit and debit cursors';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    COMMIT;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Currency Code: '||p_currency_code);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      IF(PG_DIAGNOSTICS = 'Y') THEN
        FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
        FND_MSG_PUB.ADD;
      ELSE
        x_msg_data := x_msg_data||SQLERRM;
      END IF;

      x_cash_receipt_id := l_sel_cash_receipt_id;

END apply_credits_on_payment;

/*============================================================
  | PRIVATE procedure apply_credits_on_credit_memo
  |
  | DESCRIPTION
  |   Applies selected credits against selected debits
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
  | 02-FEB-2005   vnb          Created
  +============================================================*/

PROCEDURE apply_credits_on_credit_memo(p_currency_code         IN VARCHAR2,
                                       x_open_invoices_status  OUT NOCOPY VARCHAR2,
                                       x_dup_appln_dbt_psid    OUT NOCOPY NUMBER,
                                       x_dup_appln_crdt_psid   OUT NOCOPY NUMBER,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2,
                                       x_return_status         OUT NOCOPY VARCHAR2
                        ) IS

   CURSOR debit_transactions(p_currency_code VARCHAR2) IS
   SELECT   CUSTOMER_ID,
            CUSTOMER_SITE_USE_ID,
            CUSTOMER_TRX_ID,
            TRX_NUMBER,
            TRX_DATE,
            TRX_CLASS,
            DUE_DATE,
            PAYMENT_SCHEDULE_ID,
            STATUS,
            TERMS_SEQUENCE_NUMBER,
            LINE_AMOUNT,
            TAX_AMOUNT ,
            FREIGHT_AMOUNT,
            FINANCE_CHARGES,
            CURRENCY_CODE ,
            AMOUNT_DUE_ORIGINAL,
            AMOUNT_DUE_REMAINING,
            SERVICE_CHARGE,
            DISCOUNT_AMOUNT,
            APPLICATION_AMOUNT,
            CASH_RECEIPT_ID
   FROM     ar_irec_apply_credit_gt
   WHERE    CURRENCY_CODE        = p_currency_code
   AND      ( TRX_CLASS = 'INV' OR
              TRX_CLASS = 'DM' OR
              TRX_CLASS = 'CB' OR
              TRX_CLASS = 'DEP'
	        )
   ORDER BY AMOUNT_DUE_REMAINING ASC;

   CURSOR credit_transactions(p_currency_code VARCHAR2) IS
   SELECT   CUSTOMER_ID,
            CUSTOMER_SITE_USE_ID,
            CUSTOMER_TRX_ID,
            TRX_NUMBER,
            TRX_DATE,
            TRX_CLASS,
            DUE_DATE,
            PAYMENT_SCHEDULE_ID,
            STATUS,
            TERMS_SEQUENCE_NUMBER,
            LINE_AMOUNT,
            TAX_AMOUNT ,
            FREIGHT_AMOUNT,
            FINANCE_CHARGES,
            CURRENCY_CODE ,
            AMOUNT_DUE_ORIGINAL,
            AMOUNT_DUE_REMAINING,
            SERVICE_CHARGE,
            DISCOUNT_AMOUNT,
            APPLICATION_AMOUNT,
            CASH_RECEIPT_ID
   FROM     ar_irec_apply_credit_gt
   WHERE    CURRENCY_CODE        = p_currency_code
   AND      ( TRX_CLASS = 'CM' OR
              TRX_CLASS = 'PMT'
	        )
   ORDER BY PAYMENT_SCHEDULE_ID;

   debit_trx_record           debit_transactions%ROWTYPE;
   credit_trx_record          credit_transactions%ROWTYPE;

   l_next_transaction         VARCHAR2(10);
   l_debit_application_amount NUMBER;
   l_credit_application_amount NUMBER;
   l_credit_trx_class         VARCHAR2(20);

   l_receivable_application_id ar_receivable_applications.receivable_application_id%TYPE;
   l_acctd_amount_applied_from ar_receivable_applications.acctd_amount_applied_from%TYPE;
   l_acctd_amount_applied_to   ar_receivable_applications.acctd_amount_applied_to%TYPE;

   l_return_status           VARCHAR2(10);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(255);

   l_defaulting_rule_used    VARCHAR2(255);
   l_error_message           VARCHAR2(255);

   l_application_amount      NUMBER;

   l_open_gl_date            DATE;
   l_gl_date                 DATE;
   l_inv_date                DATE;
   l_receipt_date            DATE;

   l_found                   VARCHAR2(1);

   l_procedure_name          VARCHAR2(50);
   l_debug_info	 	         VARCHAR2(200);

BEGIN
    x_msg_count                := 0;
    x_msg_data                 := '*';
    x_open_invoices_status     := 'N';
    x_return_status            := FND_API.G_RET_STS_ERROR;

    l_procedure_name           := '.apply_credits_on_credit_memo';
    l_debit_application_amount := 0;
    l_credit_application_amount:= 0;
    l_next_transaction         := 'BOTH';
    l_gl_date                  := sysdate;

    SAVEPOINT ARI_APPLY_CREDITS_CM;


    ---------------------------------------------------------------------------
    l_debug_info := 'Open the credit and debit cursors';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;
    OPEN  debit_transactions(p_currency_code);
    OPEN  credit_transactions(p_currency_code);

    LOOP
        ---------------------------------------------------------------------------
        l_debug_info := 'Fetch debit and credit transactions';
        ---------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug(l_debug_info);
        END IF;

        IF (l_next_transaction = 'DEBIT') THEN
            FETCH debit_transactions INTO debit_trx_record;
        ELSIF (l_next_transaction = 'CREDIT') THEN
            FETCH credit_transactions INTO credit_trx_record;
        ELSIF (l_next_transaction = 'BOTH') THEN
            FETCH debit_transactions INTO debit_trx_record;
            FETCH credit_transactions INTO credit_trx_record;
         END IF;

        EXIT WHEN ((debit_transactions%NOTFOUND) AND (credit_transactions%NOTFOUND));

	--Bug 4105891 - Check if there will be a non-zero remaining amount on the invoice after application
        IF (l_next_transaction = 'BOTH' OR l_next_transaction = 'DEBIT') THEN
            IF (debit_trx_record.amount_due_remaining
                     - ( debit_trx_record.discount_amount + debit_trx_record.application_amount) > 0) THEN
                    x_open_invoices_status := 'Y';
            END IF;
        END IF;

        l_debit_application_amount  := debit_trx_record.application_amount;
        l_credit_application_amount := - credit_trx_record.application_amount;
        l_credit_trx_class          := credit_trx_record.trx_class;

        -- Compare the application amount for the credit and debit transactions,
        -- to decide what should be the next transaction to be considered for application.
        IF (l_debit_application_amount > l_credit_application_amount) THEN

            l_next_transaction   := 'CREDIT';
            l_application_amount := l_credit_application_amount;
            debit_trx_record.application_amount := l_debit_application_amount - l_credit_application_amount;

        ELSIF (l_debit_application_amount < l_credit_application_amount) THEN

            l_next_transaction   := 'DEBIT';
            l_application_amount := l_debit_application_amount;
	    --Bug 4042557 - Change sign in credit application amount
            credit_trx_record.application_amount := -(l_credit_application_amount - l_debit_application_amount);

        ELSE

            l_next_transaction   := 'BOTH';
            l_application_amount := l_debit_application_amount;

        END IF;

        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug('-------Debit Transaction Information------');
            arp_standard.debug('Customer Id: ' || debit_trx_record.customer_id);
            arp_standard.debug('Customer Site Use Id: ' || debit_trx_record.customer_site_use_id);
            arp_standard.debug('Customer Trx Id: ' || debit_trx_record.customer_trx_id);
            arp_standard.debug('Trx Number: ' || debit_trx_record.trx_number);
            arp_standard.debug('Trx Date: ' || debit_trx_record.trx_date);
            arp_standard.debug('Trx Class: ' || debit_trx_record.trx_class);
            arp_standard.debug('Due Date: ' || debit_trx_record.due_date);
            arp_standard.debug('Payment Schedule Id: ' || debit_trx_record.payment_schedule_id);
            arp_standard.debug('Status: ' || debit_trx_record.status);
            arp_standard.debug('Terms Sequence Number: ' || debit_trx_record.terms_sequence_number);
            arp_standard.debug('Line Amount: ' || debit_trx_record.line_amount);
            arp_standard.debug('Tax Amount: ' || debit_trx_record.tax_amount);
            arp_standard.debug('Freight Amount: ' || debit_trx_record.freight_amount);
            arp_standard.debug('Finance Charges: ' || debit_trx_record.trx_class);
            arp_standard.debug('Currency Code: ' || debit_trx_record.currency_code);
            arp_standard.debug('Amount Due Original: ' || debit_trx_record.amount_due_original);
            arp_standard.debug('Amount Due Remaining: ' || debit_trx_record.amount_due_remaining);
            arp_standard.debug('Discount Amount: ' || debit_trx_record.discount_amount);
            arp_standard.debug('Application Amount: ' || debit_trx_record.application_amount);
            arp_standard.debug('Cash Receipt Id: ' || debit_trx_record.cash_receipt_id);
            arp_standard.debug('-------Credit Transaction Information------');
            arp_standard.debug('Customer Id: ' || credit_trx_record.customer_id);
            arp_standard.debug('Customer Site Use Id: ' || credit_trx_record.customer_site_use_id);
            arp_standard.debug('Customer Trx Id: ' || credit_trx_record.customer_trx_id);
            arp_standard.debug('Trx Number: ' || credit_trx_record.trx_number);
            arp_standard.debug('Trx Date: ' || credit_trx_record.trx_date);
            arp_standard.debug('Trx Class: ' || credit_trx_record.trx_class);
            arp_standard.debug('Due Date: ' || credit_trx_record.due_date);
            arp_standard.debug('Payment Schedule Id: ' || credit_trx_record.payment_schedule_id);
            arp_standard.debug('Status: ' || credit_trx_record.status);
            arp_standard.debug('Terms Sequence Number: ' || credit_trx_record.terms_sequence_number);
            arp_standard.debug('Line Amount: ' || credit_trx_record.line_amount);
            arp_standard.debug('Tax Amount: ' || credit_trx_record.tax_amount);
            arp_standard.debug('Freight Amount: ' || credit_trx_record.freight_amount);
            arp_standard.debug('Finance Charges: ' || credit_trx_record.trx_class);
            arp_standard.debug('Currency Code: ' || credit_trx_record.currency_code);
            arp_standard.debug('Amount Due Original: ' || credit_trx_record.amount_due_original);
            arp_standard.debug('Amount Due Remaining: ' || credit_trx_record.amount_due_remaining);
            arp_standard.debug('Discount Amount: ' || credit_trx_record.discount_amount);
            arp_standard.debug('Application Amount: ' || credit_trx_record.application_amount);
            arp_standard.debug('Cash Receipt Id: ' || credit_trx_record.cash_receipt_id);
        END IF;

        -- Bug 4103527 - Display error icons for duplicate application
        BEGIN

            select 'Y'
            into   l_found
            from   ar_receivable_applications rap
            where  rap.payment_schedule_id = credit_trx_record.payment_schedule_id
            and    rap.applied_payment_schedule_id = debit_trx_record.payment_schedule_id
            and    rap.display = 'Y'
            and    rap.status = 'APP';

            IF l_found = 'Y' THEN
                x_dup_appln_dbt_psid  := debit_trx_record.payment_schedule_id;
                x_dup_appln_crdt_psid := credit_trx_record.payment_schedule_id;

                ROLLBACK TO ARI_APPLY_CREDITS_CM;

                FND_MESSAGE.SET_NAME('AR', 'AR_RW_PAID_INVOICE_TWICE' );
                FND_MSG_PUB.ADD;

                AR_IREC_PAYMENTS.write_error_messages(x_msg_data,x_msg_count);
                RETURN;
            END IF;
        EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		null;
        END;

        IF ( l_credit_trx_class = 'CM') THEN
            ---------------------------------------------------------------------------
            l_debug_info := 'Apply credit memo against the debit transaction';
            ---------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;

	    --Bug 4042557: Fetch the GL date for the credit memo
            select trunc(gl_date),  trunc(trx_date)
            into   l_gl_date, l_receipt_date
            from ar_payment_schedules
            where payment_schedule_id = credit_trx_record.payment_schedule_id;

            select trunc(gl_date)
            into   l_inv_date
            from ar_payment_schedules
            where payment_schedule_id = debit_trx_record.payment_schedule_id;

           --Bug 5911297 - Using apply credit applied GL date profile and pass appropriate gl date
            IF(FND_PROFILE.VALUE('AR_APPLICATION_GL_DATE_DEFAULT') = 'INV_REC_SYS_DT') THEN
               l_gl_date := Greatest(l_inv_date, l_receipt_date, trunc(sysdate));
            ELSIF(FND_PROFILE.VALUE('AR_APPLICATION_GL_DATE_DEFAULT') = 'INV_REC_DT') THEN
               l_gl_date := Greatest(l_inv_date, l_receipt_date, l_gl_date);
            END IF;
	    --Bug 6062210: Fetch the open GL date for the credit memo
	if(arp_util.validate_and_default_gl_date( gl_date => l_gl_date,
				       trx_date => l_receipt_date,
                                       validation_date1       => null,
                                       validation_date2       => null,
                                       validation_date3       => null,
                                       default_date1          => null,
                                       default_date2          => null,
                                       default_date3          => null,
                                       p_allow_not_open_flag  => null,
                                       p_invoicing_rule_id    => null,
                                       p_set_of_books_id      => null,
                                       p_application_id      => 222,
                                       default_gl_date => l_open_gl_date,
                                       defaulting_rule_used  => l_defaulting_rule_used,
                                       error_message       =>  l_error_message)) then

        l_gl_date := l_open_gl_date;

	end if;


            arp_process_application.cm_application(
	               p_cm_ps_id       => credit_trx_record.payment_schedule_id,
	               p_invoice_ps_id  => debit_trx_record.payment_schedule_id,
                   p_amount_applied => l_application_amount,
                   p_apply_date     => trunc(sysdate),
	               p_gl_date        => l_gl_date,
	               p_ussgl_transaction_code => null,
	               p_attribute_category  => null,
	               p_attribute1 => null,
	               p_attribute2 => null,
	               p_attribute3 => null,
	               p_attribute4 => null,
	               p_attribute5 => null,
	               p_attribute6 => null,
	               p_attribute7 => null,
	               p_attribute8 => null,
	               p_attribute9 => null,
	               p_attribute10 => null,
	               p_attribute11 => null,
	               p_attribute12 => null,
	               p_attribute13 => null,
	               p_attribute14 => null,
	               p_attribute15 => null,
                   p_global_attribute_category => null,
                   p_global_attribute1 => null,
                   p_global_attribute2 => null,
                   p_global_attribute3 => null,
                   p_global_attribute4 => null,
                   p_global_attribute5 => null,
                   p_global_attribute6 => null,
                   p_global_attribute7 => null,
                   p_global_attribute8 => null,
                   p_global_attribute9 => null,
                   p_global_attribute10 => null,
                   p_global_attribute11 => null,
                   p_global_attribute12 => null,
                   p_global_attribute13 => null,
                   p_global_attribute14 => null,
                   p_global_attribute15 => null,
                   p_global_attribute16 => null,
                   p_global_attribute17 => null,
                   p_global_attribute18 => null,
                   p_global_attribute19 => null,
                   p_global_attribute20 => null,
                   p_customer_trx_line_id => null,
                   p_comments => null,
                   p_module_name  => null,
                   p_module_version  => null,
                   p_out_rec_application_id => l_receivable_application_id,
                   p_acctd_amount_applied_from =>l_acctd_amount_applied_from,
                   p_acctd_amount_applied_to=>l_acctd_amount_applied_to);

                IF (l_receivable_application_id IS NULL) THEN
                    FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
                    FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
                    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
                    FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
                    FND_MSG_PUB.ADD;

                    ROLLBACK TO ARI_APPLY_CREDITS_CM;
                    RETURN;
                END IF;

        ELSIF ( l_credit_trx_class = 'PMT') THEN
            ---------------------------------------------------------------------------
            l_debug_info := 'Apply receipt against the debit transaction';
            ---------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;
            AR_RECEIPT_API_PUB.apply(
                    p_api_version           => 1.0,
                    p_init_msg_list         => FND_API.G_TRUE,
                    p_commit                => FND_API.G_FALSE,
                    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    p_cash_receipt_id       => credit_trx_record.cash_receipt_id,
                    p_customer_trx_id       => debit_trx_record.customer_trx_id,
                    p_applied_payment_schedule_id => debit_trx_record.payment_schedule_id,
                    p_amount_applied        => l_application_amount,
                    p_discount              => 0,
                    p_called_from           => 'IREC',
                    p_apply_date            => trunc(sysdate)
                    );

            -- Check for error
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := l_msg_count;
                x_msg_data  := l_msg_data;
                ROLLBACK TO ARI_APPLY_CREDITS_CM;
                RETURN;
            END IF;

        END IF;

    END LOOP;

    ---------------------------------------------------------------------------
    l_debug_info := 'Close the credit and debit cursors';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;
    CLOSE credit_transactions;
    CLOSE debit_transactions;

    COMMIT;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Currency Code: '||p_currency_code);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

     IF(PG_DIAGNOSTICS = 'Y') THEN
        FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
        FND_MSG_PUB.ADD;
      ELSE
        x_msg_data := x_msg_data||SQLERRM;
      END IF;

END apply_credits_on_credit_memo;

/*============================================================
  | PUBLIC procedure copy_apply_credits_records
  |
  | DESCRIPTION
  |   Copy the open debits for the active customer, site and currency from the
  |   Apply Credits GT to the Transaction List GT
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
  | 12-OCT-2004   vnb          Created
  +============================================================*/

PROCEDURE copy_apply_credits_records( p_customer_id           IN NUMBER,
                                      p_customer_site_use_id  IN NUMBER DEFAULT NULL,
                                      p_currency_code         IN VARCHAR2
                                     ) IS

  CURSOR open_debits_list (p_customer_id NUMBER,
                            p_customer_site_use_id NUMBER,
                            p_currency_code VARCHAR2) IS

  SELECT
        CUSTOMER_ID,
        CUSTOMER_SITE_USE_ID,
        TRX_CLASS,
        PAYMENT_SCHEDULE_ID,
        CURRENCY_CODE
   FROM ar_irec_apply_credit_gt
   WHERE PAY_FOR_CUSTOMER_ID = p_customer_id
   AND ( (PAY_FOR_CUSTOMER_SITE_ID IS NULL AND p_customer_site_use_id IS NULL) OR CUSTOMER_SITE_USE_ID = nvl(p_customer_site_use_id,CUSTOMER_SITE_USE_ID))
   AND CURRENCY_CODE = p_currency_code
   AND ( TRX_CLASS = 'INV' OR
         TRX_CLASS = 'DM' OR
         TRX_CLASS = 'CB' OR
         TRX_CLASS = 'DEP'
	   )
   AND (AMOUNT_DUE_REMAINING - (nvl(DISCOUNT_AMOUNT,0) + APPLICATION_AMOUNT) > 0);

   l_procedure_name           VARCHAR2(50);
   l_debug_info	 	          VARCHAR2(200);

BEGIN

    l_procedure_name           := '.copy_apply_credits_records';


    ----------------------------------------------------------------------------------------
    l_debug_info := 'Clear the Transaction List GT for the active customer, site, currency code';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    DELETE FROM AR_IREC_PAYMENT_LIST_GT
    WHERE CUSTOMER_ID = p_customer_id
    AND CUSTOMER_SITE_USE_ID = nvl(p_customer_site_use_id,CUSTOMER_SITE_USE_ID)
    AND CURRENCY_CODE = p_currency_code;

    ----------------------------------------------------------------------------------------
    l_debug_info := 'Fetch open debits from Apply Credits GT into Transaction List GT';
    -----------------------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    FOR trx IN open_debits_list(p_customer_id,
                                p_customer_site_use_id,
                                p_currency_code )
    LOOP
        AR_IREC_PAYMENTS.create_transaction_list_record(
                                        p_payment_schedule_id   => trx.payment_schedule_id,
					p_customer_id           => p_customer_id,
					p_customer_site_id  => p_customer_site_use_id
                                    );

    END LOOP;

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

END copy_apply_credits_records;

/*============================================================
  | PUBLIC procedure select_credit_to_apply
  |
  | DESCRIPTION
  |   Select credit to apply other transactions against
  |
  | PSEUDO CODE/LOGIC
  |
  | PARAMETERS
  |   p_customer_id               IN NUMBER
  |   p_customer_site_use_id      IN NUMBER DEFAULT NULL
  |   p_currency_code             IN VARCHAR2
  |   x_return_status          OUT VARCHAR2  Returns 'S' if successful; 'E' if duplicate application
  |   x_credit_ps_id           OUT NUMBER
  |   x_debit_ps_id            OUT NUMBER    Returns debit payment schedule id if duplicate application; else null
  |
  | KNOWN ISSUES
  |
  | NOTES
  |
  |
  | MODIFICATION HISTORY
  | Date          Author       Description of Changes
  | 02-FEB-2005   vnb          Created
  | 07-SEP-2005 7 rrsaneve Updated the cursors credit_to_apply ,duplicate_application as bug#6311033 fix.
  +============================================================*/
PROCEDURE select_credit_to_apply( p_currency_code         IN VARCHAR2,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_credit_ps_id       OUT NOCOPY NUMBER,
                                  x_debit_ps_id        OUT NOCOPY NUMBER)
IS
    CURSOR credit_to_apply (p_currency_code VARCHAR2) IS
    select acgt.payment_schedule_id
    from ar_irec_apply_credit_gt acgt
    where acgt.currency_code        = p_currency_code
    and   acgt.trx_class            = 'PMT'
    and (not exists
        (
            select arp.payment_schedule_id
            from ar_receivable_applications arp, ar_irec_apply_credit_gt acgt1
            where acgt1.currency_code        = p_currency_code
            and arp.applied_payment_schedule_id = acgt1.payment_schedule_id
            and arp.payment_schedule_id = acgt.payment_schedule_id
        )
	or ( (
            select sum(amount_applied)
            from ar_receivable_applications arp, ar_irec_apply_credit_gt acgt1
            where acgt1.currency_code        = p_currency_code
            and arp.applied_payment_schedule_id = acgt1.payment_schedule_id
            and arp.payment_schedule_id = acgt.payment_schedule_id) = 0
	    )
	)
    order by acgt.trx_date asc;

    /*

    CURSOR duplicate_application(p_currency_code VARCHAR2) IS
    select acgt.payment_schedule_id, arp.applied_payment_schedule_id
    from ar_irec_apply_credit_gt acgt,ar_receivable_applications_all arp,ar_irec_apply_credit_gt acgt1
    where acgt.currency_code        = p_currency_code
    and   acgt.trx_class            = 'PMT'
    and   acgt.payment_schedule_id   = arp.payment_schedule_id
    and   acgt1.currency_code        = p_currency_code
    and  acgt1.payment_schedule_id = arp.applied_payment_schedule_id;

    */
/* bug#6311033-APPLY CREDIT FAILS WITH YOU HAVE PAID SAME INVOICE TWICE ERROR */

    CURSOR duplicate_application(p_currency_code VARCHAR2) IS
    select acgt.payment_schedule_id, arp.applied_payment_schedule_id
    from ar_irec_apply_credit_gt acgt,ar_receivable_applications_all arp,ar_irec_apply_credit_gt acgt1
    where acgt.currency_code        = p_currency_code
    and   acgt.trx_class            = 'PMT'
    and   acgt.payment_schedule_id   = arp.payment_schedule_id
    and   acgt1.currency_code        = p_currency_code
    and  acgt1.payment_schedule_id = arp.applied_payment_schedule_id
    and (
	    select sum(amount_applied)
            from ar_receivable_applications arp, ar_irec_apply_credit_gt acgt1
            where acgt1.currency_code        = p_currency_code
            and arp.applied_payment_schedule_id = acgt1.payment_schedule_id
            and arp.payment_schedule_id = acgt.payment_schedule_id) > 0;


    l_procedure_name          VARCHAR2(50);
    l_debug_info	 	      VARCHAR2(200);

    credit_to_apply_record       credit_to_apply%ROWTYPE;
    duplicate_application_record duplicate_application%ROWTYPE;

BEGIN
    x_return_status     := FND_API.G_RET_STS_ERROR;
    x_credit_ps_id      := 0;
    x_debit_ps_id       := 0;

    l_procedure_name    := '.select_credit_to_apply';

    ---------------------------------------------------------------------------
    l_debug_info := 'Open the cursor to select credit to apply';
    ---------------------------------------------------------------------------
    IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug(l_debug_info);
    END IF;

    OPEN credit_to_apply(p_currency_code);
    FETCH credit_to_apply INTO x_credit_ps_id;

    IF (credit_to_apply%FOUND) THEN
         x_return_status     := FND_API.G_RET_STS_SUCCESS;
    ELSE
        ---------------------------------------------------------------------------
        l_debug_info := 'Open the cursor to return duplicate application transactions';
        ---------------------------------------------------------------------------
        IF (PG_DEBUG = 'Y') THEN
            arp_standard.debug(l_debug_info);
        END IF;
        OPEN duplicate_application(p_currency_code);
        FETCH duplicate_application INTO duplicate_application_record;

        IF (duplicate_application%FOUND) THEN
            ---------------------------------------------------------------------------
            l_debug_info := 'If a record is found, return the credit and debit transaction';
            ---------------------------------------------------------------------------
            IF (PG_DEBUG = 'Y') THEN
                arp_standard.debug(l_debug_info);
            END IF;

            x_credit_ps_id  := duplicate_application_record.payment_schedule_id;
            x_debit_ps_id   := duplicate_application_record.applied_payment_schedule_id;

        END IF;

        CLOSE duplicate_application;

      END IF;

      CLOSE credit_to_apply;

EXCEPTION
    WHEN OTHERS THEN
      IF (PG_DEBUG = 'Y') THEN
        arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
        arp_standard.debug('- Currency Code: '||p_currency_code);
        arp_standard.debug('ERROR =>'|| SQLERRM);
      END IF;

      FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', G_PKG_NAME || l_procedure_name);
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      FND_MSG_PUB.ADD;
END select_credit_to_apply;

END AR_IREC_APPLY_CREDITS ;


/
