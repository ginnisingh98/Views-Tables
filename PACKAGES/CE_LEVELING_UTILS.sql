--------------------------------------------------------
--  DDL for Package CE_LEVELING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_LEVELING_UTILS" AUTHID CURRENT_USER as
/* $Header: celutils.pls 120.4 2006/05/05 11:27:17 svali ship $ */

PROCEDURE Generate_Button(p_as_of_date		DATE,
			p_accept_limit_error	VARCHAR2,
			p_run_id VARCHAR2);

PROCEDURE Cash_Leveling (errbuf			OUT NOCOPY VARCHAR2,
			retcode			OUT NOCOPY NUMBER,
			p_as_of_date		IN VARCHAR2,
			p_accept_limit_error 	IN VARCHAR2,
			p_run_id VARCHAR2);

PROCEDURE Generate_Fund_Transfer (X_from_bank_account_id	NUMBER,
			 	X_to_bank_account_id		NUMBER,
				X_cashpool_id			NUMBER,
				X_amount			NUMBER,
				X_transfer_date			DATE,
				X_settlement_authorized		VARCHAR2,
				X_accept_limit_error		VARCHAR2,
				X_request_id			NUMBER,
				X_deal_type	OUT NOCOPY	VARCHAR2,
				X_deal_no	OUT NOCOPY	NUMBER,
				X_trx_number	OUT NOCOPY	NUMBER,
				X_offset_deal_no OUT NOCOPY	NUMBER,
				X_offset_trx_number OUT NOCOPY	NUMBER,
				X_success_flag 	OUT NOCOPY	VARCHAR2,
				X_statement_line_id		NUMBER,
				X_msg_count	OUT NOCOPY	NUMBER,
				X_cashflows_created_flag OUT NOCOPY VARCHAR2,
				X_called_by_flag		VARCHAR2);

PROCEDURE Populate_Nested_Accounts(p_parent_cashpool_id NUMBER,
				p_cashpool_id NUMBER);

PROCEDURE Delete_Sub_Accounts(p_cashpool_id NUMBER);

PROCEDURE Update_Parent_Nested_Accounts(p_cashpool_id NUMBER,
				p_parent_cashpool_id NUMBER);

PROCEDURE Populate_Target_Balances(p_bank_account_id	NUMBER,
				p_min_target_balance	NUMBER,
				p_max_target_balance 	NUMBER,
				p_min_payment_amt	NUMBER,
				p_min_receipt_amt	NUMBER,
				p_round_factor		VARCHAR2,
				p_round_rule		VARCHAR2);

PROCEDURE Populate_BAT_Payment_Details(p_bank_account_id	NUMBER,
				p_payment_method_code		VARCHAR2,
				p_bank_charge_bearer_code	VARCHAR2,
				p_payment_reason_code		VARCHAR2,
				p_payment_reason_comments	VARCHAR2,
				p_remittance_message1		VARCHAR2,
				p_remittance_message2		VARCHAR2,
				p_remittance_message3		VARCHAR2);

PROCEDURE Update_Bank_Account_Id(p_old_bank_account_id	NUMBER,
				p_new_bank_account_id	NUMBER);

FUNCTION Match_Cashpool(p_header_bank_account_id	IN NUMBER,
                    	p_offset_bank_account_num	IN VARCHAR2,
                    	p_trx_type 			IN VARCHAR2,
                    	p_trx_date			IN DATE,
                    	p_offset_bank_account_id 	OUT NOCOPY NUMBER,
                    	p_cashpool_id            	OUT NOCOPY NUMBER)
		RETURN BOOLEAN;

END CE_LEVELING_UTILS;

 

/
