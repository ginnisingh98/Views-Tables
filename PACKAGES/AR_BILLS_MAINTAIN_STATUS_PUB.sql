--------------------------------------------------------
--  DDL for Package AR_BILLS_MAINTAIN_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_MAINTAIN_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: ARBRSVES.pls 115.4 2002/11/15 02:03:23 anukumar ship $ */


PROCEDURE  Validate_actions
		( 	p_customer_trx_id		IN 	NUMBER			,
			p_complete_flag			OUT NOCOPY 	VARCHAR2 		,
			p_uncomplete_flag		OUT NOCOPY	VARCHAR2		,
			p_accept_flag			OUT NOCOPY	VARCHAR2		,
			p_cancel_flag			OUT NOCOPY	VARCHAR2		,
			p_select_remit_flag		OUT NOCOPY	VARCHAR2		,
			p_deselect_remit_flag		OUT NOCOPY	VARCHAR2		,
			p_approve_remit_flag		OUT NOCOPY	VARCHAR2		,
			p_hold_flag			OUT NOCOPY	VARCHAR2		,
			p_unhold_flag			OUT NOCOPY	VARCHAR2		,
			p_recall_flag			OUT NOCOPY	VARCHAR2		,
			p_eliminate_flag		OUT NOCOPY	VARCHAR2		,
			p_uneliminate_flag		OUT NOCOPY	VARCHAR2		,
			p_unpaid_flag			OUT NOCOPY	VARCHAR2		,
			p_protest_flag			OUT NOCOPY	VARCHAR2		,
			p_endorse_flag			OUT NOCOPY	VARCHAR2		,
			p_restate_flag			OUT NOCOPY	VARCHAR2		,
			p_exchange_flag			OUT NOCOPY	VARCHAR2		,
			p_delete_flag			OUT NOCOPY	VARCHAR2		);


PROCEDURE  New_Status_Event
		( 	p_trx_rec			IN 	ra_customer_trx%ROWTYPE	,
			p_action        		IN 	VARCHAR2		,
			p_new_status			OUT NOCOPY 	VARCHAR2		,
			p_new_event			OUT NOCOPY 	VARCHAR2		);


FUNCTION   Is_BR_Matured
		(	p_maturity_date			IN	DATE					)
			RETURN BOOLEAN;


FUNCTION   Is_Acceptance_Required
		(	p_cust_trx_type_id 		IN  	ra_customer_trx.cust_trx_type_id%TYPE	)
			RETURN BOOLEAN;


FUNCTION   Is_Payment_Schedule_Reduced
		(	p_ps_rec  			IN  	ar_payment_schedules%ROWTYPE		)
			RETURN BOOLEAN;

FUNCTION   Is_BR_Reserved
		(	p_ps_rec  			IN  	ar_payment_schedules%ROWTYPE		)
			RETURN BOOLEAN;

PROCEDURE  Find_Last_relevant_trh
		(	p_trh_rec  			IN  OUT NOCOPY	ar_transaction_history%ROWTYPE		);


FUNCTION   Activities_Exist
		(	p_customer_trx_id 		IN 	NUMBER					)
			RETURN BOOLEAN;

FUNCTION   Has_been_posted
		(	p_customer_trx_id 		IN  	NUMBER					)
			RETURN BOOLEAN;

FUNCTION   revision
			RETURN VARCHAR2;


END AR_BILLS_MAINTAIN_STATUS_PUB ;

 

/
