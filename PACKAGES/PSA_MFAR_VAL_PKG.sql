--------------------------------------------------------
--  DDL for Package PSA_MFAR_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MFAR_VAL_PKG" AUTHID CURRENT_USER as
/* $Header: PSAMFVLS.pls 120.5 2006/09/13 14:07:49 agovil ship $ */

PROCEDURE AR_MFAR_VALIDATE_TRX_HEADER (
X_TRANSACTION_TYPE_ID 		Number ,
X_TRANSACTION_CLASS	        varchar2	,
X_TRX_COMMITMENT_NUMBER		varchar2	,
X_TRANSACTION_RULES_FLAG	        varchar2	,
X_INVOICE_RULE_ID	        	Number		,
X_RECEIPT_METHOD_ID             Number,
X_SET_OF_BOOKS_ID		Number		,
X_BASE_CURRENCY_CODE	        varchar2
);

/* The following procedure will check if a Credit Memo is of Multi Fund
   transaction type or not
*/

PROCEDURE AR_MFAR_CM_VAL_CHECK (
X_TRX_ID    	in 	number ,
X_SET_OF_BOOKS_ID	in	number,
X_BASE_CURRENCY_CODE    in      varchar2                               );

/* The following procedure will be called from either Transactions , Receipts
   or Adjustments Distributions Form . Depending upon the Source Type this
   procedure will validate the Transaction Type
*/
FUNCTION AR_MFAR_VALIDATE_CHECK(
X_SOURCE_ID		in 	Number,
X_SOURCE_TYPE		in 	varchar2,
X_SET_OF_BOOKS_ID	in 	Number )
RETURN   varchar2;

FUNCTION AR_MFAR_RECEIPT_CHECK(
X_RECEIPT_ID             in      Number,
X_RECEIPT_METHOD_ID      in      varchar2,
X_TRANSACTION_ID           in      number)
RETURN   varchar2;
/*
FUNCTION AR_MFAR_RECEIPT_REVERSAL_CHECK(
X_RECEIPT_ID             in      Number
)
RETURN   varchar2;
*/

PROCEDURE AR_MFAR_QUICKCASH(X_RECEIPT_METHOD_ID in  NUMBER);

FUNCTION AR_LOCKBOX_VALIDATION
RETURN  VARCHAR2  ;

/* The following procedure will check if a transaction is of Multi Fund
   transaction type or not
*/
/*
PROCEDURE TRANSACTION_VALIDATION_CHECK (
X_TRANSACTION_ID		in ra_customer_trx.customer_trx_id%type ,
X_ACCOUNTING_METHOD		in varchar2,
X_RETURN_SATUS			out NOCOPY varchar2);
*/
/* The following procedure will check if a Receipt Header is of Multi Fund
   transaction type or not
*/
/*
PROCEDURE RECEIPT_HEADER_VALIDATION_CHECK (
X_TRANSACTION_ID           in   ra_customer_trx.customer_trx_id%type ,
X_ACCOUNTING_METHOD             in varchar2,
X_RETURN_SATUS                  out NOCOPY varchar2);
*/
/* The following procedure will check if the Receipt is applied to Multi Fund
   transaction type or not
*/
/*
PROCEDURE RECEIPT_VALIDATION_CHECK (
X_CASH_RECEIPT_ID		in   ,
X_TRANSACTION_TYPE_ID           in ra_customer_trx.customer_trx_id%type ,
X_ACCOUNTING_METHOD             in varchar2,
X_RETURN_SATUS                  out NOCOPY varchar2);
*/
/* The following procedure will check if the adjustment is applied to a
   Multi Fund Transaction type or not
*/
/*
PROCEDURE ADJUSTMENT_VALIDATION_CHECK (
X_ADJUSTMENT_ID           in varchar2,
X_TRANSACTION_ID          in  ra_customer_trx.customer_trx_id%type ,
X_ACCOUNTING_METHOD       in varchar2,
X_RETURN_SATUS            out NOCOPY varchar2);
*/
PROCEDURE ar_mfar_autoinv_trx_header(l_request_id  in NUMBER);



/*===============================================================
  Function to validate a Miscellaneous Receipt.
  A Miscellaneous Receipt is of Type Multi-fund if
	--> The Receivable Activity is flagged as Multi-Fund type from Setup form

  For a Multi-Fund type Misc Receipt, the Payment Method should
  not require Confirmation / Remittance. If these validations are
  not met, ERROR is raised during WHEN-VALIDATE-RECORD of Misc. receipts header.
  ==================================================================*/

FUNCTION MISC_RCT_VAL
		( 	p_cash_receipt_id	IN	NUMBER,
			p_receipt_method_id 	IN	NUMBER,
			p_receivables_trx_id	IN	NUMBER
		) return varchar2;




end PSA_MFAR_VAL_PKG;

 

/
