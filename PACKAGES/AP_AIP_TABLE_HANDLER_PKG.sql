--------------------------------------------------------
--  DDL for Package AP_AIP_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AIP_TABLE_HANDLER_PKG" AUTHID CURRENT_USER AS
/*$Header: apaipths.pls 120.5 2005/04/15 01:42:53 yicao noship $*/

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
        P_org_id                IN      NUMBER            Default NULL);


PROCEDURE Update_Amounts(
        P_invoice_payment_id    IN      NUMBER,
        P_amount                IN      NUMBER,
        P_invoice_base_amount   IN      NUMBER,
        P_payment_base_amount   IN      NUMBER,
        P_calling_sequence      IN      VARCHAR2);


END AP_AIP_TABLE_HANDLER_PKG;

 

/
