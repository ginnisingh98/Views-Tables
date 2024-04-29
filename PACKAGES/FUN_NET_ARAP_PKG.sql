--------------------------------------------------------
--  DDL for Package FUN_NET_ARAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_ARAP_PKG" AUTHID CURRENT_USER AS
/* $Header: funnttxs.pls 120.8.12010000.3 2009/04/18 07:17:32 ychandra ship $ */

PROCEDURE get_functional_currency;

FUNCTION get_batch_details RETURN BOOLEAN;

FUNCTION get_agreement_details RETURN BOOLEAN;

FUNCTION update_batch_status(p_status VARCHAR2) RETURN BOOLEAN;

FUNCTION prepare_ar_transactions RETURN BOOLEAN;

FUNCTION prepare_ap_transactions RETURN BOOLEAN;

PROCEDURE insert_transactions(p_inv_cur VARCHAR2,
				p_currency_code VARCHAR2,
				p_appln VARCHAR2);

PROCEDURE calculate_AP_AR_balances(p_amt_to_net OUT NOCOPY NUMBER,
                                    p_status_flag OUT NOCOPY VARCHAR2);

PROCEDURE validate_AP_AR_balances(p_ar_bal OUT NOCOPY NUMBER,
                                    p_ap_bal OUT NOCOPY NUMBER,
                                    p_status_flag OUT NOCOPY VARCHAR2);

PROCEDURE insert_batch_record(p_currency_code VARCHAR2);

FUNCTION batch_exists(p_currency_code VARCHAR2) RETURN BOOLEAN;

PROCEDURE update_net_balances(p_sql_stmt VARCHAR2,
                                    p_amt_to_net NUMBER,
                                    p_appln VARCHAR2);

PROCEDURE Update_Net_Amounts(p_batch_id NUMBER,
                                    p_amt_to_net NUMBER,
                                    p_appln VARCHAR2);

PROCEDURE create_net_batch(
            -- ***** Standard API Parameters *****
            p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
            p_commit        IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,

            -- ***** Netting batch input parameters *****
            p_batch_id      IN NUMBER);

PROCEDURE submit_net_batch (
            -- ***** Standard API Parameters *****
            p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id          IN  NUMBER);

FUNCTION Validate_Netting_Dates(
            -- ***** Standard API Parameters *****
            p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id          IN NUMBER,
            p_net_settle_date   IN DATE,
            p_response_date     IN DATE) RETURN VARCHAR2;

 PROCEDURE settle_ap_invs(
 	p_bank_acct_use_id  IN ce_bank_acct_uses_all.bank_acct_use_id%TYPE,
       	p_bank_acct_name   	IN ce_bank_accounts.bank_account_name%TYPE,
        p_bank_acct_num    	IN ce_bank_accounts.bank_account_num%TYPE,
        p_le_id		  	IN xle_entity_profiles.legal_entity_id%TYPE,
  	p_bank_num         	IN ce_banks_v.bank_number%TYPE,
	x_return_status    	OUT NOCOPY  VARCHAR2);

FUNCTION Calculate_AR_Txn_Open_Amt(
	p_customer_trx_id   IN ra_customer_trx.customer_trx_id%TYPE,
	p_inv_currency_code IN ra_customer_trx.invoice_currency_code%TYPE,
	p_exchange_rate     IN ra_customer_trx.exchange_rate%TYPE)
RETURN NUMBER;

PROCEDURE settle_net_batch (
            -- ***** Standard API Parameters *****
            p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id          IN  NUMBER);

 PROCEDURE Get_Netting_Bank_Details(
         p_bank_acct_use_id OUT NOCOPY  NUMBER,
         p_bank_acct_name OUT NOCOPY VARCHAR2,
         p_bank_acct_num OUT NOCOPY ce_bank_accounts.bank_account_num%TYPE,
         p_le_id  	 OUT NOCOPY NUMBER,
         p_bank_num	 OUT NOCOPY VARCHAR2,
         p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Get_Customer_Details (
	     p_cust_acct_id 	OUT NOCOPY NUMBER,
             p_cust_site_use_id OUT NOCOPY NUMBER,
             p_return_status 	OUT NOCOPY VARCHAR2);


FUNCTION Derive_Net_Exchg_Rate(
	    x_from_currency IN VARCHAR2,
            x_to_currency IN VARCHAR2)
RETURN NUMBER;

FUNCTION Derive_Conv_Amt(
	p_batch_id NUMBER,
	p_trx_id NUMBER,
	p_amount NUMBER,
	ap_ar VARCHAR2)
RETURN NUMBER;


FUNCTION calculate_ar_trx_amt(
		p_customer_trx_id NUMBER)
RETURN NUMBER;

PROCEDURE unlock_ap_pymt_schedules(
		p_batch_id		IN fun_net_batches.batch_id%TYPE,
                x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE Set_Agreement_Status(
            x_batch_id  IN fun_net_batches.batch_id%TYPE,
            x_agreement_id IN fun_net_agreements.agreement_id%TYPE,
            x_mode	    IN  VARCHAR2,
	    x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Settlement_Period(
	x_appln_id       IN fnd_application.application_id%TYPE,
	x_period_name    OUT NOCOPY VARCHAR2,
        x_return_status  OUT NOCOPY VARCHAR2,
	x_return_msg	  OUT NOCOPY VARCHAR2);

FUNCTION get_ap_discount(
	p_batch_id NUMBER,
	p_invoice_id NUMBER,
	p_amt_to_net NUMBER,
	p_txn_due_date DATE
) RETURN NUMBER;

FUNCTION get_ar_discount(
	p_batch_id NUMBER,
	p_cust_txn_id NUMBER,
	p_amt_to_net NUMBER,
	p_txn_due_date DATE
) RETURN NUMBER;

FUNCTION get_esd_flag(
	p_batch_id NUMBER
) RETURN VARCHAR2;

END FUN_NET_ARAP_PKG; -- Package spec

/
