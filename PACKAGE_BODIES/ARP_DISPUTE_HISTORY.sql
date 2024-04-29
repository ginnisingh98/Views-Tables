--------------------------------------------------------
--  DDL for Package Body ARP_DISPUTE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DISPUTE_HISTORY" AS
/* $Header: ARPLMDHB.pls 120.2 2002/11/18 21:51:05 anukumar ship $ */

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
			        p_lastUpdateLogin	IN	NUMBER ) IS
   BEGIN

      UPDATE       ar_dispute_history
      SET     end_date = nvl(p_DisputeDate,
				greatest(p_OldDisputeDate, sysdate))
      WHERE   payment_schedule_id = p_PaymentScheduleId
      AND     end_date IS NULL;


      INSERT INTO ar_dispute_history (
        dispute_history_id,
        payment_schedule_id,
        amount_in_dispute,
        amount_due_remaining,
        dispute_amount,
        start_date,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login )
      VALUES (
        ar_dispute_history_s.nextval,
        p_OldPaymentScheduleId,
        NVL(p_AmountInDispute, 0),
        p_AmountDueRemaining,
        DECODE(p_OldAmountInDispute, NULL, NVL(p_AmountInDispute,0),
                (NVL(p_AmountInDispute,0) - p_OldAmountInDispute)),
        nvl(p_DisputeDate, greatest(p_OldDisputeDate, sysdate)),
        p_CreatedBy,
        p_CreationDate,
        p_LastUpdatedBy,
        p_LastUpdateDate,
        p_lastUpdateLogin );

      IF p_AmountInDispute IS NULL THEN

         p_DisputeDate := NULL;

      END IF;

    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_dispute_history.DisputeHistory');
            RAISE;
   END;



END ARP_DISPUTE_HISTORY;

/
