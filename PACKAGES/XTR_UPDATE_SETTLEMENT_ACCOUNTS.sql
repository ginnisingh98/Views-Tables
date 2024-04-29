--------------------------------------------------------
--  DDL for Package XTR_UPDATE_SETTLEMENT_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_UPDATE_SETTLEMENT_ACCOUNTS" AUTHID CURRENT_USER as
/* $Header: xtrupacs.pls 120.1 2005/07/29 17:11:40 rjose noship $ */

--------------------------------------
-- global variables
--------------------------------------
G_user_id	NUMBER;
G_create_date	DATE;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE process_settlement_accounts
 *
 * DESCRIPTION
 *     	This procedure updates XTR_DEAL_DATE_AMOUNTS table and sets the
 * 	company account or counterparty account specified as the
 *	account_number_from to the account specified as account_number_to.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     	p_party_code                  	Party Code of the party for whom the
 *					accounts are to be updated.
 *     	p_current_bank_account		Bank Account Number from
 *					XTR_BANK_ACCOUNTS for the above party.
 *					All cashflow records that use this
 *					account are to be updated.
 *	p_new_bank_account		Bank Account Number from
 *					XTR_BANK_ACCOUNTS for the above party.
 *					All cashflow records that use the
 *					above account will be updated with this
 *					account.
 *	p_start_date			All records with an amount_date greater
 *					than or equal to this date will be
 *					considered for update.
 *	p_end_date			All records with an amount_date lesser
 *					than or equal to this date will be
 *					considered for update.
 *	p_deal_type			Only those deals with the specified
 *					Deal Type will be updated.
 *	p_deal_number_from		Only those deals with a deal number
 *					greater than or equal to this
 *					parameter will be updated.
 *	p_deal_number_to		Only those deals with a deal number
 *					lesser than or equal to this
 *					parameter will be updated.
 *	p_include_journalized		Flag to indicate whether cashflows
 *					that have already been journalized
 *					should be updated.
 *   IN/OUT:
 *   OUT:
 *	p_error_buf			Standard Error Buffer
 *	p_retcode
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-Jun-2005    Rajesh Jose        	o Created.
 *
 */
PROCEDURE Process_Settlement_Accounts(
	p_error_buf		OUT NOCOPY VARCHAR2,
	p_retcode		OUT NOCOPY NUMBER,
	p_party_code 		IN XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_current_bank_account 	IN XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_new_bank_account 	IN XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_start_date 		IN VARCHAR2,
	p_end_date 		IN VARCHAR2,
	p_deal_type 		IN XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number_from 	IN XTR_DEALS.DEAL_NO%TYPE,
	p_deal_number_to	IN XTR_DEALS.DEAL_NO%TYPE,
	p_include_journalized	IN
		XTR_CFLOW_REQUEST_DETAILS.INCLUDE_JOURNALIZED_FLAG%TYPE);


/**
 * PROCEDURE insert_request_details
 *
 * DESCRIPTION
 *     	Inserts request details into XTR_CFLOW_REQUEST_DETAILS table so that
 *	the execution report can be run at any time.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_cashflow_request_details_id	The identifier for the record.
 *	p_request_id			The Request ID of the Concurrent
 *					Request that was run to update the
 *					Settlement Accounts.
 *     	p_party_code                  	Party Code Parameter from the request.
 *     	p_current_bank_account		Current Bank Account Number Parameter
 *					from the request.
 *	p_new_bank_account		New Bank Account Number Parameter
 *					from request.
 *	p_start_date			Start Date Parameter from the request.
 *	p_end_date			End Date Parameter from the request.
 *	p_deal_type			Deal Type Parameter from the request.
 *	p_deal_number_from		Deal Number From Parameter from the
 *					request.
 *	p_deal_number_to		Deal Number To Parameter from the
 *					request.
 *	p_inc_journalized		Include Journalized Transactions
 *					Parameter from the request.
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-Jun-2005    Rajesh Jose        	o Created.
 */
PROCEDURE Insert_Request_Details(
	p_cashflow_request_details_id IN
		XTR_CFLOW_REQUEST_DETAILS.CASHFLOW_REQUEST_DETAILS_ID%TYPE,
	p_request_id 		IN	NUMBER,
	p_party_code 		IN	XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_current_bank_account 	IN	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_new_bank_account 	IN	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_deal_type 		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number_from 	IN	XTR_DEALS.DEAL_NO%TYPE,
	p_deal_number_to 	IN	XTR_DEALS.DEAL_NO%TYPE,
	p_start_date 		IN	DATE,
	p_end_date 		IN	DATE,
	p_inc_journalized	IN
		XTR_CFLOW_REQUEST_DETAILS.INCLUDE_JOURNALIZED_FLAG%TYPE);


/**
 * PROCEDURE insert_transaction_details
 *
 * DESCRIPTION
 *	Inserts details of transactions updated by the concurrent request
 *	so that the Execution Report shows accurate data at any point of time.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_cashflow_request_details_id	Foreign key reference from
 *					XTR_CFLOW_REQUEST_DETAILS.
 *	p_amount_date			The amount date of the cashflow.
 *	p_amount_type			The type of cashflow.
 *	p_cashflow_amount		The amount of cash flow.
 *	p_deal_type			The Deal Type for the record.
 *	p_deal_number			The Deal Number for the record.
 *	p_transaction_number		The Transaction Number for the record.
 *	p_updated_flag			Flag indicating whether the record was
 *					updated or not.
 *	p_message_name			Message to be shown if record was not
 *					updated. Conveys the reason why the
 *					record was not updated.
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *   06-Jun-2005    Rajesh Jose        	o Created.
 *
 */

PROCEDURE Insert_Transaction_Details(
	p_cashflow_request_details_id 	IN
		XTR_CFLOW_REQUEST_DETAILS.CASHFLOW_REQUEST_DETAILS_ID%TYPE,
	p_amount_date		IN	DATE,
	p_amount_type		IN	XTR_DEAL_DATE_AMOUNTS.AMOUNT_TYPE%TYPE,
	p_cashflow_amount	IN
				XTR_DEAL_DATE_AMOUNTS.CASHFLOW_AMOUNT%TYPE,
	p_deal_type		IN	XTR_DEAL_DATE_AMOUNTS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN
				XTR_DEAL_DATE_AMOUNTS.TRANSACTION_NUMBER%TYPE,
	p_updated_flag		IN	VARCHAR2,
	p_message_name		IN	VARCHAR2);


END XTR_UPDATE_SETTLEMENT_ACCOUNTS;


 

/
