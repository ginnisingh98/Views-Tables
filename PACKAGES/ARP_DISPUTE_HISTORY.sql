--------------------------------------------------------
--  DDL for Package ARP_DISPUTE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DISPUTE_HISTORY" AUTHID CURRENT_USER AS
/* $Header: ARPLMDHS.pls 120.1 2002/11/15 02:42:15 anukumar ship $ */

PROCEDURE DisputeHistory(	p_DisputeDate		IN OUT NOCOPY	DATE,
				p_OldDisputeDate	IN 	DATE,
				p_PaymentScheduleId	IN	NUMBER,
				p_OldPaymentScheduleId	IN	NUMBER,
				p_AmountDueRemaining	IN	NUMBER,
				p_AmountInDispute	IN	NUMBER,
				p_OldAmountInDispute	IN	NUMBER,
			        p_CreatedBy		IN	NUMBER,
			        p_CreationDate		IN	DATE,
			        p_LastUpdatedBy		IN	NUMBER,
			        p_LastUpdateDate	IN	DATE,
			        p_lastUpdateLogin	IN	NUMBER );

END ARP_DISPUTE_HISTORY;

 

/
