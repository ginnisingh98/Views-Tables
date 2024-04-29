--------------------------------------------------------
--  DDL for Package AR_BILLS_MAINTAIN_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_MAINTAIN_LIB_PVT" AUTHID CURRENT_USER AS
/* $Header: ARBRMALS.pls 120.4 2005/10/30 03:48:53 appldev ship $ */


PROCEDURE Get_Doc_Seq
		(	p_appid			IN	NUMBER					,
			p_trx_rec		IN OUT NOCOPY	RA_CUSTOMER_TRX%ROWTYPE			,
			p_sob_id		IN	NUMBER					,
			p_met_code		IN	VARCHAR2				);



PROCEDURE Get_Remittance_Batch
		(	p_customer_trx_id	IN 	NUMBER					,
			p_batch_rec		OUT NOCOPY 	ar_batches%ROWTYPE			);


PROCEDURE Update_Reserved_Columns
		(	p_payment_schedule_id	IN 	NUMBER					,
			p_reserved_type     	IN 	VARCHAR2				,
			p_reserved_value	IN	NUMBER					);


PROCEDURE Default_Action_Dates
		(	p_trx_date		IN OUT NOCOPY	AR_TRANSACTION_HISTORY.trx_date%TYPE	,
			p_gl_date		IN OUT NOCOPY	AR_TRANSACTION_HISTORY.gl_date%TYPE 	);


PROCEDURE Complete_Acc_Required
		(	p_customer_trx_id  	IN 	ra_customer_trx.customer_trx_id%TYPE	);


PROCEDURE Complete_OR_Accept
	      	( 	p_trh_rec		IN OUT NOCOPY	ar_transaction_history%ROWTYPE		);


PROCEDURE Create_Adjustment
		( 	p_trh_rec		IN  	ar_transaction_history%ROWTYPE		,
			p_customer_trx_id	IN	ra_customer_trx.customer_trx_id%TYPE	,
			p_ps_rec		IN	ar_payment_schedules%ROWTYPE		,
			p_amount		IN	NUMBER					,
			p_receivables_trx_id	IN  	ar_receivables_trx.receivables_trx_id%TYPE,
			p_status		IN  	VARCHAR2				,
			p_move_deferred_tax	IN	VARCHAR2				,
			p_adj_id		OUT NOCOPY 	ar_adjustments.adjustment_id%TYPE	);


PROCEDURE Find_Last_Adjustment
	      	(	p_customer_trx_id 	IN 	ra_customer_trx.customer_trx_id%TYPE	,
			p_adj_id	  	OUT NOCOPY	ar_adjustments.adjustment_id%TYPE	);


PROCEDURE Approve_Adjustment
		(	p_adj_id	  	IN	ar_adjustments.adjustment_id%TYPE	,
			p_move_deferred_tax	IN	VARCHAR2				) ;


PROCEDURE Modify_Adjustment
		(	p_adj_id  		IN 	AR_ADJUSTMENTS.adjustment_id%TYPE	,
			p_status		IN	AR_ADJUSTMENTS.status%TYPE	 	);


PROCEDURE Reverse_Adjustment
	      	( 	p_adj_id 		IN 	AR_ADJUSTMENTS.adjustment_id%TYPE	,
			p_trh_rec		IN	AR_TRANSACTION_HISTORY%ROWTYPE		,
			p_called_from		IN	VARCHAR2				);


PROCEDURE Reverse_Assignments_Adjustment
	      	( 	p_trh_rec		IN	ar_transaction_history%ROWTYPE		,
  	  		p_acceptance_flag	IN	VARCHAR2				);


PROCEDURE Find_Last_Receipt
		(	p_customer_trx_id  	IN 	ra_customer_trx.customer_trx_id%TYPE	,
			p_cash_receipt_id  	OUT NOCOPY	ar_cash_receipts.cash_receipt_id%TYPE	);


PROCEDURE Find_Last_STD
		( 	p_customer_trx_id  	IN 	ra_customer_trx.customer_trx_id%TYPE	,
			p_cash_receipt_id  	OUT NOCOPY	ar_cash_receipts.cash_receipt_id%TYPE	,
			p_receivable_application_id OUT NOCOPY	ar_receivable_applications.receivable_application_id%TYPE);


PROCEDURE Reverse_Receipt
		(	p_trh_rec   		IN  	ar_transaction_history%ROWTYPE		,
			p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
			p_reversal_reason	IN	VARCHAR2	 			,
			p_called_from		IN	VARCHAR2				);


PROCEDURE Apply_Receipt
		(	p_trh_rec		IN	ar_transaction_history%ROWTYPE		,
			p_ps_rec		IN	ar_payment_schedules%ROWTYPE		,
			p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
			p_called_from		IN	VARCHAR2				);


PROCEDURE Unapply_Receipt
		(	p_trh_rec   		IN  	ar_transaction_history%ROWTYPE		,
			p_ps_id			IN	ar_payment_schedules.payment_schedule_id%TYPE,
			p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
			p_called_from		IN	VARCHAR2				);


PROCEDURE Apply_STD
		(	p_customer_trx_id	IN	ra_customer_trx.customer_trx_id%TYPE	,
			p_cash_receipt_id	IN	ar_cash_receipts.cash_receipt_id%TYPE	,
			p_apply_date		IN	DATE					,
			p_apply_gl_date		IN	DATE					);

PROCEDURE Unapply_STD
		(	p_trh_rec		IN	ar_transaction_history%ROWTYPE		,
			p_called_from		IN	VARCHAR2				,
			p_cash_receipt_id	OUT NOCOPY	ar_cash_receipts.cash_receipt_id%TYPE	);


PROCEDURE Factore_Recourse
	      	(	p_batch_rec		IN	ar_batches%ROWTYPE			,
			p_ps_rec		IN	ar_payment_schedules%ROWTYPE		,
			p_trh_rec		IN	ar_transaction_history%ROWTYPE		);

PROCEDURE Factore_Without_Recourse
		(	p_batch_rec		IN	ar_batches%ROWTYPE			,
			p_ps_rec		IN	ar_payment_schedules%ROWTYPE		);

PROCEDURE Unpaid
		(	p_trh_rec   		IN OUT NOCOPY 	ar_transaction_history%ROWTYPE		,
			p_ps_id			IN	ar_payment_schedules.payment_schedule_id%TYPE,
			p_remittance_batch_id 	IN	ra_customer_trx.remittance_batch_id%TYPE,
			p_unpaid_reason		IN	VARCHAR2				);


PROCEDURE Link_Application_History
		(	p_trh_rec		IN   	ar_transaction_history%ROWTYPE		);

END AR_BILLS_MAINTAIN_LIB_PVT ;

 

/
