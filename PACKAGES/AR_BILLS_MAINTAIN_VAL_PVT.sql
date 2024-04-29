--------------------------------------------------------
--  DDL for Package AR_BILLS_MAINTAIN_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_MAINTAIN_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARBRMAVS.pls 115.2 2002/11/15 01:58:11 anukumar ship $ */


--Validation procedures are contained in this package

PROCEDURE  Validate_Complete_BR
		(	p_trx_rec		IN OUT NOCOPY		ra_customer_trx%ROWTYPE		,
			p_gl_date		IN		DATE				);


PROCEDURE  Validate_Accept_BR
		(	p_trx_rec		IN 		ra_customer_trx%ROWTYPE		,
			p_trh_rec		IN		ar_transaction_history%ROWTYPE	);


PROCEDURE  Validate_Cancel_BR
		(	p_customer_trx_id	IN 		ra_customer_trx.customer_trx_id%TYPE);


PROCEDURE  Validate_Unpaid_BR
		(	p_trh_rec  		IN 		ar_transaction_history%ROWTYPE	,
			p_unpaid_reason		IN		VARCHAR2			);


PROCEDURE  Validate_Payment_Schedule_ID
		( 	p_payment_schedule_id	IN  		NUMBER				);


PROCEDURE  Validate_Remit_Batch_ID
		(	p_batch_id 		IN  		NUMBER				);


PROCEDURE  Validate_Adj_Activity_ID
		(	p_adjustment_activity_id IN  		NUMBER				);


PROCEDURE  Validate_Action_Dates
		( 	p_trx_date		IN		DATE				,
			p_gl_date		IN		DATE				,
			p_trh_rec		IN		ar_transaction_history%ROWTYPE	,
			p_action		IN		VARCHAR2			);


PROCEDURE  Validate_Remittance_Dates
		(	p_batch_rec		IN		ar_batches%ROWTYPE		,
			p_trh_rec		IN		ar_transaction_history%ROWTYPE	,
			p_trx_number		IN		ra_customer_trx.trx_number%TYPE	);

END AR_BILLS_MAINTAIN_VAL_PVT;

 

/
