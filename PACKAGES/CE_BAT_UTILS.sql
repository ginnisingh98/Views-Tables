--------------------------------------------------------
--  DDL for Package CE_BAT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BAT_UTILS" AUTHID CURRENT_USER as
/* $Header: cebtutls.pls 120.10 2006/08/24 09:42:49 svali noship $ */


  G_spec_revision 				VARCHAR2(1000) := '$Revision: 120.10 $';

  G_trxn_reference_number		CE_PAYMENT_TRANSACTIONS.trxn_reference_number%type;
  G_trxn_subtype_code_id		CE_PAYMENT_TRANSACTIONS.trxn_subtype_code_id%type;
  G_transaction_date			CE_PAYMENT_TRANSACTIONS.transaction_date%type;
  G_anticipated_value_date		CE_PAYMENT_TRANSACTIONS.anticipated_value_date%type;
  G_transaction_desc			CE_PAYMENT_TRANSACTIONS.transaction_description%type;
  G_payment_curr_code			CE_PAYMENT_TRANSACTIONS.payment_currency_code%type;
  G_payment_amount				CE_PAYMENT_TRANSACTIONS.payment_amount%type;
  G_source_party_id				CE_PAYMENT_TRANSACTIONS.source_party_id%type;
  G_source_le_id				CE_PAYMENT_TRANSACTIONS.source_legal_entity_id%type;
  G_source_bank_acct_id			CE_PAYMENT_TRANSACTIONS.source_bank_account_id%type;
  G_dest_party_id				CE_PAYMENT_TRANSACTIONS.destination_party_id%type;
  G_dest_le_id					CE_PAYMENT_TRANSACTIONS.destination_legal_entity_id%type;
  G_dest_bank_acct_id			CE_PAYMENT_TRANSACTIONS.destination_bank_account_id%type;
  G_created_from_dir			CE_PAYMENT_TRANSACTIONS.created_from_dir%type;
  G_created_from_stmtline_id	CE_PAYMENT_TRANSACTIONS.create_from_stmtline_id%type;
  G_bank_trxn_number			CE_PAYMENT_TRANSACTIONS.bank_trxn_number%type;
  G_payment_offset_ccid			CE_PAYMENT_TRANSACTIONS.payment_offset_ccid%type;
  G_receipt_offset_ccid			CE_PAYMENT_TRANSACTIONS.receipt_offset_ccid%type;

  G_payment_request_id			CE_PAYMENT_TRANSACTIONS.payment_request_number%TYPE;


  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE transfer_payment_transaction ( p_trxn_reference_number     NUMBER,
								   p_multi_currency			   VARCHAR2,
								   p_mode		OUT     NOCOPY	   VARCHAR2,
								   p_cashflow_id1	OUT	NOCOPY	   NUMBER,
								   p_cashflow_id2	OUT	NOCOPY	   NUMBER);

  FUNCTION get_exchange_rate_type(p_le_id number) RETURN VARCHAR2;

  PROCEDURE get_exchange_rate_date(p_ledger_id number,
			   	 p_bank_account_id number,
				 p_legal_entity_id number,
			   	 p_exch_type IN OUT NOCOPY varchar2,
			   	 p_exchange_date OUT NOCOPY date,
			   	 p_exchange_rate OUT NOCOPY number);

  FUNCTION get_exchange_date_type(p_le_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_ledger_id (l_le_id  NUMBER) RETURN NUMBER;

  FUNCTION get_accounting_status(p_cashflow_number	NUMBER) RETURN VARCHAR2;

  PROCEDURE call_payment_process_request (p_payment_request_id    NUMBER,
					  			  p_request_id	 OUT NOCOPY  NUMBER
					 );

  FUNCTION get_bsv (p_cash_ccid NUMBER, p_ledger_id NUMBER) RETURN VARCHAR2;

  PROCEDURE get_intercompany_ccid (p_from_le_id NUMBER,
						 p_to_le_id NUMBER,
						 p_from_cash_gl_ccid NUMBER,
						 p_to_cash_gl_ccid NUMBER,
						 p_transfer_date DATE,
						 p_acct_type VARCHAR2,
			             p_status OUT NOCOPY VARCHAR2,
			             p_msg_count OUT NOCOPY NUMBER,
			             p_msg_data OUT NOCOPY VARCHAR2,
			             p_ccid OUT NOCOPY NUMBER,
			             p_reciprocal_ccid OUT NOCOPY NUMBER,
			             p_result OUT NOCOPY VARCHAR2);

  PROCEDURE get_bat_default_pmt_method
		(p_payer_le_id NUMBER,
		 p_org_id NUMBER,
		 p_payee_party_id NUMBER,
		 p_payee_party_site_id NUMBER,
		 p_supplier_site_id NUMBER,
		 p_payment_currency VARCHAR2,
		 p_payment_amount NUMBER,
		 x_return_status OUT NOCOPY VARCHAR2 ,
		 x_msg_data OUT NOCOPY VARCHAR2 ,
		 x_msg_count OUT NOCOPY NUMBER ,
		 x_def_pm_code OUT NOCOPY VARCHAR2 ,
		 x_def_pm_name OUT NOCOPY VARCHAR2 );


END CE_BAT_UTILS;


 

/
