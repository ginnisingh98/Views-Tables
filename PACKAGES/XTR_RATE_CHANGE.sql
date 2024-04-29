--------------------------------------------------------
--  DDL for Package XTR_RATE_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_RATE_CHANGE" AUTHID CURRENT_USER AS
/* $Header: xtrpdrts.pls 120.1 2005/06/29 10:48:18 rjose ship $ */

PROCEDURE PRODUCT_RATE_CHANGE(
	errbuf       			OUT NOCOPY VARCHAR2,
	retcode      			OUT NOCOPY VARCHAR2,
	p_effective_from_date		IN	VARCHAR2,
    	p_eff_from_next_rollover_yn     IN    	VARCHAR2,
	p_new_interest_rate		IN	VARCHAR2,
	p_change_pi_yn			IN	VARCHAR2,
	p_deal_subtype			IN	VARCHAR2,
	p_payment_schedule_code		IN	VARCHAR2,
	p_currency			IN	VARCHAR2,
	p_min_balance			IN	NUMBER,
	p_max_balance			IN	NUMBER);


PROCEDURE RECALC_PI_AMOUNT(
	p_deal_number			IN	NUMBER,
	p_new_interest_rate 		IN 	NUMBER,
	p_effective_from_date 		IN 	DATE,
	p_eff_from_next_rollover_yn  	IN	VARCHAR2,
	p_new_pi_amount_due 		OUT 	NOCOPY NUMBER);

END XTR_RATE_CHANGE;

 

/
