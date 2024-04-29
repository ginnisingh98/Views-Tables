--------------------------------------------------------
--  DDL for Package Body AP_AIP_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AIP_TABLE_HANDLER_PKG" AS
/*$Header: apaipthb.pls 120.11 2005/10/19 22:09:53 bghose noship $*/

PROCEDURE insert_row(
	P_invoice_id		IN	NUMBER,
        P_check_id     		IN	NUMBER,
        P_payment_num	    	IN	NUMBER,
	P_invoice_payment_id	IN	NUMBER,
	P_old_invoice_payment_id IN 	NUMBER,
	P_period_name		IN   	VARCHAR2,
	P_accounting_date	IN	DATE,
	P_amount		IN	NUMBER,
	P_discount_taken	IN	NUMBER,
	P_discount_lost		IN	NUMBER,
	P_invoice_base_amount	IN	NUMBER,
	P_payment_base_amount	IN	NUMBER,
	P_accrual_posted_flag	IN	VARCHAR2,
	P_cash_posted_flag	IN 	VARCHAR2,
	P_posted_flag		IN 	VARCHAR2,
	P_set_of_books_id	IN	NUMBER,
	P_last_updated_by     	IN 	NUMBER,
	P_last_update_login	IN	NUMBER,
	P_last_update_date	IN	DATE,
	P_currency_code		IN 	VARCHAR2,
	P_base_currency_code	IN	VARCHAR2,
	P_exchange_rate		IN	NUMBER,
	P_exchange_rate_type  	IN 	VARCHAR2,
	P_exchange_date		IN 	DATE,
	P_bank_account_id	IN	NUMBER,
	P_bank_account_num	IN	VARCHAR2,
	P_bank_account_type	IN	VARCHAR2,
	P_bank_num		IN	VARCHAR2,
	P_future_pay_posted_flag  IN   	VARCHAR2,
	P_exclusive_payment_flag  IN	VARCHAR2,
	P_accts_pay_ccid     	IN	NUMBER,
	P_gain_ccid	  	IN	NUMBER,
	P_loss_ccid   	  	IN	NUMBER,
	P_future_pay_ccid    	IN	NUMBER,
	P_asset_ccid	  	IN	NUMBER,
	P_payment_dists_flag	IN	VARCHAR2,
	P_payment_mode		IN	VARCHAR2,
	P_replace_flag		IN	VARCHAR2,
	P_attribute1		IN	VARCHAR2,
	P_attribute2		IN	VARCHAR2,
	P_attribute3		IN	VARCHAR2,
	P_attribute4		IN	VARCHAR2,
	P_attribute5		IN	VARCHAR2,
	P_attribute6		IN	VARCHAR2,
	P_attribute7		IN	VARCHAR2,
	P_attribute8		IN	VARCHAR2,
	P_attribute9		IN	VARCHAR2,
	P_attribute10		IN	VARCHAR2,
	P_attribute11		IN	VARCHAR2,
	P_attribute12		IN	VARCHAR2,
	P_attribute13		IN	VARCHAR2,
	P_attribute14		IN	VARCHAR2,
	P_attribute15		IN	VARCHAR2,
	P_attribute_category	IN	VARCHAR2,
	P_global_attribute1	IN	VARCHAR2	  Default NULL,
	P_global_attribute2	IN	VARCHAR2	  Default NULL,
	P_global_attribute3	IN	VARCHAR2	  Default NULL,
	P_global_attribute4	IN	VARCHAR2	  Default NULL,
	P_global_attribute5	IN	VARCHAR2	  Default NULL,
	P_global_attribute6	IN	VARCHAR2	  Default NULL,
	P_global_attribute7	IN	VARCHAR2	  Default NULL,
	P_global_attribute8	IN	VARCHAR2	  Default NULL,
	P_global_attribute9	IN	VARCHAR2	  Default NULL,
	P_global_attribute10	IN	VARCHAR2	  Default NULL,
	P_global_attribute11	IN	VARCHAR2	  Default NULL,
	P_global_attribute12	IN	VARCHAR2	  Default NULL,
	P_global_attribute13	IN	VARCHAR2	  Default NULL,
	P_global_attribute14	IN	VARCHAR2	  Default NULL,
	P_global_attribute15	IN	VARCHAR2	  Default NULL,
	P_global_attribute16	IN	VARCHAR2	  Default NULL,
	P_global_attribute17	IN	VARCHAR2	  Default NULL,
	P_global_attribute18	IN	VARCHAR2	  Default NULL,
	P_global_attribute19	IN	VARCHAR2	  Default NULL,
	P_global_attribute20	IN	VARCHAR2	  Default NULL,
	P_global_attribute_category	  IN	VARCHAR2  Default NULL,
        P_calling_sequence      IN      VARCHAR2,
        P_accounting_event_id   IN      NUMBER            Default NULL,
        P_org_id                IN      NUMBER            Default Null)
 IS
 l_iban_number                   IBY_EXT_BANK_ACCOUNTS.IBAN%TYPE; --Bug 4535804
 current_calling_sequence        VARCHAR2(2000);
 debug_info                      VARCHAR2(100);

BEGIN
  current_calling_sequence := 'AP_AIP_TABLE_HANDLER_PKG.Insert_Row <-'
                              ||P_calling_sequence;

  IF (P_PAYMENT_MODE in ('PAY','REV')) THEN

    debug_info := 'Get the IBAN_NUMBER';
    IF  P_Check_Id is not NULL THEN
      BEGIN
        SELECT ipb.iban
          INTO  l_iban_number
          FROM  ap_checks_all ac, iby_payee_all_bankacct_v ipb  /* External Bank Uptake */
          WHERE  ac.check_id = P_check_id
           AND  ipb.ext_bank_account_id = ac.external_bank_account_id
           AND  ipb.party_id = ac.party_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_iban_number := NULL;
      END;
    END IF;

    debug_info := 'Insert ap_invoice_payments';
    INSERT INTO AP_INVOICE_PAYMENTS(
                invoice_payment_id,
                invoice_id,
                payment_num,
                check_id,
                amount,
                last_update_date,
                last_updated_by,
                set_of_books_id,
                posted_flag,
                accrual_posted_flag,
                cash_posted_flag,
                accts_pay_code_combination_id,
                accounting_date,
                period_name,
                exchange_rate_type,
                exchange_rate,
                exchange_date,
                discount_lost,
                discount_taken,
                invoice_base_amount,
                payment_base_amount,
                asset_code_combination_id,
                gain_code_combination_id,
                loss_code_combination_id,
                bank_account_num,
                iban_number,
                bank_num,
                bank_account_type,
                future_pay_code_combination_id,
                future_pay_posted_flag,
                last_update_login,
                creation_date,
                created_by,
                invoice_payment_type,
                other_invoice_id,
                reversal_inv_pmt_id,
                reversal_flag,
                accounting_event_id, -- Events Project - 2
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
                attribute_category,
                global_attribute1,
                global_attribute2,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute20,
                global_attribute_category,
                org_id,
                assets_addition_flag)
         VALUES(P_invoice_payment_id,
                P_invoice_id,
                P_payment_num,
                P_check_id,
                P_amount,
                P_last_update_date,
                P_last_updated_by,
                P_set_of_books_id,
                P_posted_flag,
                P_accrual_posted_flag,
                P_cash_posted_flag,
                P_accts_pay_ccid,
                P_accounting_date,
                P_period_name,
                P_exchange_rate_type,
                P_exchange_rate,
                P_exchange_date,
                P_discount_lost,
                P_discount_taken,
                P_invoice_base_amount,
                P_payment_base_amount,
                P_asset_ccid,
                P_gain_ccid,
                P_loss_ccid,
                P_bank_account_num,
                l_iban_number,
                P_bank_num,
                P_bank_account_type,
                P_future_pay_ccid,
                P_future_pay_posted_flag,
                P_last_update_login,
                SYSDATE,
                P_last_updated_by,
                '',
                '',
                P_old_invoice_payment_id,
                decode(P_old_invoice_payment_id, '', 'N', 'Y'),
                P_accounting_event_id, -- Events Project - 3
                P_attribute1,
                P_attribute2,
                P_attribute3,
                P_attribute4,
                P_attribute5,
                P_attribute6,
                P_attribute7,
                P_attribute8,
                P_attribute9,
                P_attribute10,
                P_attribute11,
                P_attribute12,
                P_attribute13,
                P_attribute14,
                P_attribute15,
                P_attribute_category,
                P_global_attribute1,
                P_global_attribute2,
                P_global_attribute3,
                P_global_attribute4,
                P_global_attribute5,
                P_global_attribute6,
                P_global_attribute7,
                P_global_attribute8,
                P_global_attribute9,
                P_global_attribute10,
                P_global_attribute11,
                P_global_attribute12,
                P_global_attribute13,
                P_global_attribute14,
                P_global_attribute15,
                P_global_attribute16,
                P_global_attribute17,
                P_global_attribute18,
                P_global_attribute19,
                P_global_attribute20,
                P_global_attribute_category,
                P_org_id,
                'U');

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_PAYMENTS',
               p_operation => 'I',
               p_key_value1 => P_invoice_payment_id,
                p_calling_sequence => current_calling_sequence);

    -- Mark old invoice payment as part of a reversal pair
    if (p_old_invoice_payment_id is not null) then
      update ap_invoice_payments
      set    reversal_flag = 'Y',
             last_update_date = p_last_update_date,
             last_updated_by = p_last_updated_by
      where  invoice_payment_id = p_old_invoice_payment_id;
    end if;

  end if;

  -- Update the prepay_amount_remaining if the invoice that is paid is a
  -- Prepayment Invoice.

  DECLARE
    l_invoice_type VARCHAR2(30);

  BEGIN

    SELECT invoice_type_lookup_code
    INTO   l_invoice_type
    FROM   ap_invoices
    WHERE  invoice_id = p_invoice_id;

    IF l_invoice_type = 'PREPAYMENT' THEN
       --Check for DBI2
       UPDATE ap_invoice_distributions_all
       SET    prepay_amount_remaining = total_dist_amount
       WHERE  invoice_id = p_invoice_id;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;


EXCEPTION
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
                ||', Payment_num = '||TO_CHAR(P_payment_num)
                ||', Check_id = '||TO_CHAR(P_check_id)
                ||', Invoice_payment_id = '||TO_CHAR(P_invoice_payment_id)
              ||', Old Invoice_payment_id = '||TO_CHAR(P_old_invoice_payment_id)
                ||', Accounting_date = '||TO_CHAR(P_accounting_date)
                ||', Period_name = '||P_period_name
                ||', Amount = '||TO_CHAR(P_amount)
                ||', accrual_posted_flag = '||P_accrual_posted_flag
                ||', cash_posted_flag = '||P_cash_posted_flag
                ||', posted_flag = '||P_posted_flag
                ||', discount_taken = '||TO_CHAR(P_discount_taken)
                ||', discount_lost = '||TO_CHAR(P_discount_lost)
                ||', invoice_base_amount = '||TO_CHAR(P_invoice_base_amount)
                ||', payment_base_amount = '||TO_CHAR(P_payment_base_amount)
                ||', set_of_books_id = '||TO_CHAR(P_set_of_books_id)
                ||', currency_code = '||P_currency_code
                ||', base_currency_code = '||P_base_currency_code
                ||', exchange_rate = '||TO_CHAR(P_exchange_rate)
                ||', exchange_rate_type = '||P_exchange_rate_type
                ||', exchange_date = '||TO_CHAR(P_exchange_date)
                ||', bank_account_id = '||TO_CHAR(P_bank_account_id)
                ||', bank_account_num = '||P_bank_account_num
                ||', bank_account_type = '||P_bank_account_type
                ||', bank_num = '||P_bank_num
                ||', future_pay_posted_flag = '||P_future_pay_posted_flag
                ||', exclusive_payment_flag = '||P_exclusive_payment_flag
                ||', accts_pay_ccid = '||TO_CHAR(P_accts_pay_ccid)
                ||', gain_ccid = '||TO_CHAR(P_gain_ccid)
                ||', loss_ccid = '||TO_CHAR(P_loss_ccid)
                ||', future_pay_ccid= '||TO_CHAR(P_future_pay_ccid)
                ||', asset_ccid = '||TO_CHAR(P_asset_ccid)
                ||', attribute1 = '||P_attribute1
                ||', attribute2 = '||P_attribute2
                ||', attribute3 = '||P_attribute3
                ||', attribute4 = '||P_attribute4
                ||', attribute5 = '||P_attribute5
                ||', attribute6 = '||P_attribute6
                ||', attribute7 = '||P_attribute7
                ||', attribute8 = '||P_attribute8
                ||', attribute9 = '||P_attribute9
                ||', attribute10 = '||P_attribute10
                ||', attribute11 = '||P_attribute11
                ||', attribute12 = '||P_attribute12
                ||', attribute13 = '||P_attribute13
                ||', attribute14 = '||P_attribute14
                ||', attribute15 = '||P_attribute15
                ||', attribute_category = '||P_attribute_category
                ||', Last_update_by = '||TO_CHAR(P_last_updated_by)
                ||', Last_update_date = '||TO_CHAR(P_last_update_date)
                ||', Last_update_login = '||TO_CHAR(P_last_update_login)
                ||', payment_dists_flag = '||P_payment_dists_flag
                ||', payment_mode = '||P_payment_mode
                ||', replace_flag = '||P_replace_flag);

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

end Insert_Row;



PROCEDURE Update_Amounts(
        P_invoice_payment_id    IN      NUMBER,
        P_amount                IN      NUMBER,
        P_invoice_base_amount   IN      NUMBER,
        P_payment_base_amount   IN      NUMBER,
        P_calling_sequence      IN      VARCHAR2)
IS
current_calling_sequence  VARCHAR2(2000);
debug_info                VARCHAR2(100);


Begin

  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_pay_update_inv_pay_amounts<-'||
                              P_calling_sequence;

  debug_info := 'update ap_invoice_payments amount';

  -- Update ap_invoice_payments

  UPDATE ap_invoice_payments
    SET amount = nvl(p_amount, amount),
        invoice_base_amount = nvl(p_invoice_base_amount, invoice_base_amount),
        payment_base_amount = nvl(p_payment_base_amount, payment_base_amount)
    WHERE invoice_payment_id = p_invoice_payment_id;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_PAYMENTS',
               p_operation => 'U',
               p_key_value1 => P_invoice_payment_id,
                p_calling_sequence => current_calling_sequence);

Exception
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS'
                ,' Invoice_Payment_Id = '||TO_CHAR(P_invoice_payment_id)
                ||', Amount = '||TO_CHAR(P_amount)
                ||', Invoice_Base_Amount = '||TO_CHAR(P_Invoice_Base_Amount)
                ||', Payment_Base_Amount = '||TO_CHAR(P_Payment_Base_Amount));

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

   APP_EXCEPTION.RAISE_EXCEPTION;

END update_amounts;

END AP_AIP_TABLE_HANDLER_PKG;

/
