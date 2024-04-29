--------------------------------------------------------
--  DDL for Package ARP_DISCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DISCOUNTS_API" AUTHID CURRENT_USER AS
/* $Header: ARRUDIAS.pls 120.3.12010000.2 2009/04/17 13:53:57 nproddut ship $ */

PROCEDURE get_discount
		( p_ps_id	         IN	ar_payment_schedules.payment_schedule_id%TYPE,
		  p_apply_date	         IN	DATE,
		  p_in_applied_amount    IN     NUMBER,
		  p_grace_days_flag      IN     VARCHAR2,
		  p_out_discount         OUT NOCOPY	NUMBER,
		  p_out_rem_amt_rcpt 	 OUT NOCOPY    NUMBER,
		  p_out_rem_amt_inv 	 OUT NOCOPY    NUMBER,
                  P_called_from          IN VARCHAR2 DEFAULT 'AR');

PROCEDURE get_max_discount
		( p_ps_id 	        IN 	ar_payment_schedules.payment_schedule_id%TYPE,
		  p_apply_date	        IN 	DATE,
		  p_grace_days_flag	IN	VARCHAR2,
		  p_out_discount        OUT NOCOPY	NUMBER,
		  p_out_applied_amt    OUT NOCOPY 	NUMBER);


FUNCTION get_available_disc_on_inv ( p_applied_payment_schedule_id  IN  NUMBER,
		                     p_apply_date                   IN  DATE ,
				     p_amount_to_be_applied         IN NUMBER DEFAULT NULL ) RETURN NUMBER;

END ARP_DISCOUNTS_API;

/
