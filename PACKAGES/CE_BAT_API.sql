--------------------------------------------------------
--  DDL for Package CE_BAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BAT_API" AUTHID CURRENT_USER AS
/* $Header: cebtapis.pls 120.7.12010000.3 2009/05/18 09:58:59 vnetan ship $ */
--

G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.7.12010000.3 $';

FUNCTION  spec_revision RETURN VARCHAR2;
FUNCTION  body_revision RETURN VARCHAR2;


PROCEDURE create_transfer(
	p_called_by_1 VARCHAR2,
	p_source_ba_id NUMBER,
	p_destination_ba_id NUMBER,
	p_statement_line_id NUMBER,
	p_cashpool_id NUMBER,
	p_transfer_amount NUMBER,
	p_payment_details_from VARCHAR2,
	p_as_of_date DATE,
	p_cashflows_created_flag OUT NOCOPY VARCHAR2,
	p_result OUT NOCOPY varchar2,
	p_msg_count OUT NOCOPY NUMBER,
	p_trxn_reference_number OUT NOCOPY NUMBER);

PROCEDURE check_duplicate(
	p_called_by	VARCHAR2,
	p_source_ba_id	 NUMBER,
	p_destination_ba_id	NUMBER,
	p_statement_line_id	NUMBER,
	p_transfer_amount		NUMBER,
	p_transfer_date 	DATE,
	p_pay_trxn_number OUT NOCOPY NUMBER,
	p_result OUT NOCOPY varchar2);

PROCEDURE validate_transfer(
	p_called_by VARCHAR2,
	p_trxn_reference_number NUMBER,
	p_source_le_id	NUMBER,
	p_destination_le_id	NUMBER,
	p_source_ba_currency_code VARCHAR2,
	p_destination_ba_currency_code VARCHAR2,
	p_transfer_currency_code VARCHAR2,
	p_transfer_date	DATE,
	p_source_ba_asset_ccid NUMBER,
	p_destination_ba_asset_ccid NUMBER,
	p_destination_bank_account_id NUMBER,
	p_authorize_flag VARCHAR2,
	p_settle_flag VARCHAR2,
	p_ccid	OUT NOCOPY NUMBER,
	p_reciprocal_ccid	OUT NOCOPY NUMBER,
	p_result OUT NOCOPY varchar2);

PROCEDURE initiate_transfer(
	p_called_by VARCHAR2,
	p_source_ba_id	NUMBER,
	p_destination_ba_id	NUMBER,
	p_cashpool_id	NUMBER,
	p_statement_line_id  NUMBER,
	p_transfer_amount NUMBER,
	p_as_of_date	DATE,
	p_payment_details_from VARCHAR2,
	p_result OUT NOCOPY varchar2);

PROCEDURE check_user_security(
	p_source_le_id	NUMBER,
	p_destination_le_id	NUMBER,
	p_result OUT NOCOPY varchar2);

PROCEDURE authorize_transfer(
	p_called_by VARCHAR2,
	p_trxn_reference_number	NUMBER,
	p_settle_flag VARCHAR2,
	p_pay_proc_req_code NUMBER,
	p_result OUT NOCOPY varchar2);

PROCEDURE reject_transfer(
	p_pay_trxn_number	NUMBER,
	p_result OUT NOCOPY	varchar2);

PROCEDURE cancel_transfer(
	p_pay_trxn_number	NUMBER,
	p_result OUT NOCOPY VARCHAR2);

PROCEDURE populate_transfer(
	p_pay_trxn_number OUT NOCOPY NUMBER);

PROCEDURE settle_transfer(
	p_called_by VARCHAR2,
	p_pay_trxn_number NUMBER,
	/* Bug 7559093 */
	p_payment_reference_number VARCHAR2,
	p_cashflow_id1 NUMBER,
	p_cashflow_id2 NUMBER);

PROCEDURE iby_validations(p_bank_account_id NUMBER,
				  p_trxn_reference_number NUMBER,
				  p_result OUT NOCOPY VARCHAR2);

PROCEDURE check_create_ext_bank_acct (p_bank_account_id NUMBER,
							  p_ext_bank_account_id OUT NOCOPY NUMBER,
							  p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE call_iby_validate(p_trxn_reference_number NUMBER,
					p_doc_payable_id OUT NOCOPY NUMBER,
					p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE cancel_cashflow (p_cashflow_id NUMBER,
				   p_result OUT NOCOPY VARCHAR2);

PROCEDURE create_update_cashflows(p_trxn_reference_number NUMBER,
				  p_mode OUT NOCOPY VARCHAR2,
				  p_cashflow_id1 OUT NOCOPY NUMBER,
				  p_cashflow_id2 OUT NOCOPY NUMBER);

/*bug 6046852*/
PROCEDURE validate_foreign_currency(
    p_source_le_id  NUMBER,
    p_destination_le_id NUMBER,
    p_source_ba_id VARCHAR2,
    p_destination_ba_id VARCHAR2,
    p_pmt_currency VARCHAR2, --for bug 6455698
    p_error_code  OUT NOCOPY VARCHAR2 --for bug 6455698
    );

-- bug 8459147
PROCEDURE check_gl_period(
    p_date		     DATE,
    p_source_le_id   NUMBER,
    p_destination_le_id NUMBER,
    x_period_status  OUT NOCOPY VARCHAR2);

END CE_BAT_API;

/
