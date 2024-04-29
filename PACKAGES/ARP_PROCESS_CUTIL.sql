--------------------------------------------------------
--  DDL for Package ARP_PROCESS_CUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_CUTIL" AUTHID CURRENT_USER AS
/* $Header: ARCEUTLS.pls 120.2 2005/10/30 04:14:15 appldev ship $ */
/*============================================================================+
| MODIFICATION HISTORY                                                        |
| 27-FEB-02 Pravin Pawar       Added new procedure update_ps_fdate.           |
|                              Bug:2218144                                    |
|                              This is used to update follow_up_date_last     |
|                              into PS table from cust call window.           |
+=============================================================================+*/
procedure update_ps( p_ps_id                       IN ar_payment_schedules.payment_schedule_id%TYPE,
                     p_due_date                    IN ar_payment_schedules.due_date%TYPE,
                     p_amount_in_dispute           IN ar_payment_schedules.amount_in_dispute%TYPE,
                     p_dispute_date                IN ar_payment_schedules.dispute_date%TYPE,
                     p_update_dff                  IN VARCHAR2,
                     p_attribute_category          IN ar_payment_schedules.attribute_category%TYPE,
                     p_attribute1                  IN ar_payment_schedules.attribute1%TYPE,
                     p_attribute2                  IN ar_payment_schedules.attribute2%TYPE,
                     p_attribute3                  IN ar_payment_schedules.attribute3%TYPE,
                     p_attribute4                  IN ar_payment_schedules.attribute4%TYPE,
                     p_attribute5                  IN ar_payment_schedules.attribute5%TYPE,
                     p_attribute6                  IN ar_payment_schedules.attribute6%TYPE,
                     p_attribute7                  IN ar_payment_schedules.attribute7%TYPE,
                     p_attribute8                  IN ar_payment_schedules.attribute8%TYPE,
                     p_attribute9                  IN ar_payment_schedules.attribute9%TYPE,
                     p_attribute10                 IN ar_payment_schedules.attribute10%TYPE,
                     p_attribute11                 IN ar_payment_schedules.attribute11%TYPE,
                     p_attribute12                 IN ar_payment_schedules.attribute12%TYPE,
                     p_attribute13                 IN ar_payment_schedules.attribute13%TYPE,
                     p_attribute14                 IN ar_payment_schedules.attribute14%TYPE,
                     p_attribute15                 IN ar_payment_schedules.attribute15%TYPE,
                     p_staged_dunning_level        IN ar_payment_schedules.staged_dunning_level%TYPE DEFAULT NULL,
                     p_dunning_level_override_date IN ar_payment_schedules.dunning_level_override_date%TYPE DEFAULT NULL,
                     p_global_attribute_category   IN ar_payment_schedules.global_attribute_category%TYPE,
                     p_global_attribute1           IN ar_payment_schedules.global_attribute1%TYPE,
                     p_global_attribute2           IN ar_payment_schedules.global_attribute2%TYPE,
                     p_global_attribute3           IN ar_payment_schedules.global_attribute3%TYPE,
                     p_global_attribute4           IN ar_payment_schedules.global_attribute4%TYPE,
                     p_global_attribute5           IN ar_payment_schedules.global_attribute5%TYPE,
                     p_global_attribute6           IN ar_payment_schedules.global_attribute6%TYPE,
                     p_global_attribute7           IN ar_payment_schedules.global_attribute7%TYPE,
                     p_global_attribute8           IN ar_payment_schedules.global_attribute8%TYPE,
                     p_global_attribute9           IN ar_payment_schedules.global_attribute9%TYPE,
                     p_global_attribute10          IN ar_payment_schedules.global_attribute10%TYPE,
                     p_global_attribute11          IN ar_payment_schedules.global_attribute11%TYPE,
                     p_global_attribute12          IN ar_payment_schedules.global_attribute12%TYPE,
                     p_global_attribute13          IN ar_payment_schedules.global_attribute13%TYPE,
                     p_global_attribute14          IN ar_payment_schedules.global_attribute14%TYPE,
                     p_global_attribute15          IN ar_payment_schedules.global_attribute15%TYPE,
                     p_global_attribute16          IN ar_payment_schedules.global_attribute16%TYPE,
                     p_global_attribute17          IN ar_payment_schedules.global_attribute17%TYPE,
                     p_global_attribute18          IN ar_payment_schedules.global_attribute18%TYPE,
                     p_global_attribute19          IN ar_payment_schedules.global_attribute19%TYPE,
                     p_global_attribute20          IN ar_payment_schedules.global_attribute20%TYPE
                   ) ;
procedure update_ps( p_ps_id                       IN ar_payment_schedules.payment_schedule_id%TYPE,
                     p_due_date                    IN ar_payment_schedules.due_date%TYPE,
                     p_amount_in_dispute           IN ar_payment_schedules.amount_in_dispute%TYPE,
                     p_dispute_date                IN ar_payment_schedules.dispute_date%TYPE,
                     p_update_dff                  IN VARCHAR2,
                     p_attribute_category          IN ar_payment_schedules.attribute_category%TYPE,
                     p_attribute1                  IN ar_payment_schedules.attribute1%TYPE,
                     p_attribute2                  IN ar_payment_schedules.attribute2%TYPE,
                     p_attribute3                  IN ar_payment_schedules.attribute3%TYPE,
                     p_attribute4                  IN ar_payment_schedules.attribute4%TYPE,
                     p_attribute5                  IN ar_payment_schedules.attribute5%TYPE,
                     p_attribute6                  IN ar_payment_schedules.attribute6%TYPE,
                     p_attribute7                  IN ar_payment_schedules.attribute7%TYPE,
                     p_attribute8                  IN ar_payment_schedules.attribute8%TYPE,
                     p_attribute9                  IN ar_payment_schedules.attribute9%TYPE,
                     p_attribute10                 IN ar_payment_schedules.attribute10%TYPE,
                     p_attribute11                 IN ar_payment_schedules.attribute11%TYPE,
                     p_attribute12                 IN ar_payment_schedules.attribute12%TYPE,
                     p_attribute13                 IN ar_payment_schedules.attribute13%TYPE,
                     p_attribute14                 IN ar_payment_schedules.attribute14%TYPE,
                     p_attribute15                 IN ar_payment_schedules.attribute15%TYPE
                   ) ;
procedure update_ps( p_ps_id                       IN ar_payment_schedules.payment_schedule_id%TYPE,
                     p_exclude_from_dunning        IN ar_payment_schedules.exclude_from_dunning_flag%TYPE,
                     p_update_dff                  IN VARCHAR2,
                     p_attribute_category          IN ar_payment_schedules.attribute_category%TYPE,
                     p_attribute1                  IN ar_payment_schedules.attribute1%TYPE,
                     p_attribute2                  IN ar_payment_schedules.attribute2%TYPE,
                     p_attribute3                  IN ar_payment_schedules.attribute3%TYPE,
                     p_attribute4                  IN ar_payment_schedules.attribute4%TYPE,
                     p_attribute5                  IN ar_payment_schedules.attribute5%TYPE,
                     p_attribute6                  IN ar_payment_schedules.attribute6%TYPE,
                     p_attribute7                  IN ar_payment_schedules.attribute7%TYPE,
                     p_attribute8                  IN ar_payment_schedules.attribute8%TYPE,
                     p_attribute9                  IN ar_payment_schedules.attribute9%TYPE,
                     p_attribute10                 IN ar_payment_schedules.attribute10%TYPE,
                     p_attribute11                 IN ar_payment_schedules.attribute11%TYPE,
                     p_attribute12                 IN ar_payment_schedules.attribute12%TYPE,
                     p_attribute13                 IN ar_payment_schedules.attribute13%TYPE,
                     p_attribute14                 IN ar_payment_schedules.attribute14%TYPE,
                     p_attribute15                 IN ar_payment_schedules.attribute15%TYPE
                   ) ;
procedure update_ps_fdate( p_ps_id             IN ar_payment_schedules.payment_schedule_id%TYPE,
                           p_follow_up_date    IN ar_payment_schedules.follow_up_date_last%TYPE
                   ) ;
End;

 

/
