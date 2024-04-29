--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_CUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_CUTIL" AS
/* $Header: ARCEUTLB.pls 120.6 2006/06/30 08:46:10 arnkumar ship $ */

/* Declare WHO columns*/
l_last_updated_by   NUMBER   := FND_GLOBAL.USER_ID;
l_last_update_login NUMBER   := FND_GLOBAL.LOGIN_ID;
l_last_update_date  DATE     := SYSDATE;

  /*added for the bug 2641517 */
   l_term_changed_flag           VARCHAR2(1);
   l_trx_sum_hist_rec            AR_TRX_SUMMARY_HIST%rowtype;
   l_history_id                  NUMBER;
   l_trx_class                   varchar2(30);
   l_old_dispute_date            DATE;
   l_new_dispute_date            DATE;
   l_new_dispute_amount          NUMBER;
   l_sysdate                     DATE := SYSDATE;
   /* Added column dispute_date to the cursor, bug fix 5129946*/
   CURSOR get_existing_ps (p_ps_id IN NUMBER) IS
   SELECT payment_schedule_id,
          invoice_currency_code,
          due_date,
          amount_in_dispute,
          amount_due_original,
          amount_due_remaining,
          amount_adjusted,
          customer_trx_id,
          customer_id,
          customer_site_use_id,
          class,
          trx_date,
          dispute_date
   FROM   ar_payment_schedules
   WHERE  payment_schedule_id = p_ps_id;


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
                     p_staged_dunning_level        IN ar_payment_schedules.staged_dunning_level%TYPE,
                     p_dunning_level_override_date IN ar_payment_schedules.dunning_level_override_date%TYPE,
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
 ) IS
BEGIN

   OPEN get_existing_ps(p_ps_id);
       FETCH get_existing_ps INTO
             l_trx_sum_hist_rec.payment_schedule_id,
             l_trx_sum_hist_rec.currency_code,
             l_trx_sum_hist_rec.due_date,
             l_trx_sum_hist_rec.amount_in_dispute,
             l_trx_sum_hist_rec.amount_due_original,
             l_trx_sum_hist_rec.amount_due_remaining,
             l_trx_sum_hist_rec.amount_adjusted,
             l_trx_sum_hist_rec.customer_trx_id,
             l_trx_sum_hist_rec.customer_id,
             l_trx_sum_hist_rec.site_use_id,
             l_trx_class,
             l_trx_sum_hist_rec.trx_date,
             l_old_dispute_date;

         IF l_trx_sum_hist_rec.due_date <> p_due_date
            OR nvl(l_trx_sum_hist_rec.amount_in_dispute,0)
                                 <> nvl(p_amount_in_dispute,0)
          THEN

             AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                                      l_history_id,
                                                      l_trx_class,
                                                      'MODIFY_TRX');
         END IF;
         /*Bug 5129946: Calling arp_dispute_history.DisputeHistory*/
         IF get_existing_ps%ROWCOUNT>0 THEN
         l_new_dispute_amount := p_amount_in_dispute;
         l_new_dispute_date := p_dispute_date;
         if(l_new_dispute_amount <> l_trx_sum_hist_rec.amount_in_dispute)
            OR (l_new_dispute_amount IS NULL and l_trx_sum_hist_rec.amount_in_dispute IS NOT NULL)
            OR (l_new_dispute_amount IS  NOT NULL and l_trx_sum_hist_rec.amount_in_dispute IS  NULL)
            THEN
            arp_dispute_history.DisputeHistory(l_new_dispute_date,
                                               l_old_dispute_date,
                                               l_trx_sum_hist_rec.payment_schedule_id,
                                               l_trx_sum_hist_rec.payment_schedule_id,
                                               l_trx_sum_hist_rec.amount_due_remaining,
                                               l_new_dispute_amount,
                                               l_trx_sum_hist_rec.amount_in_dispute,
                                               l_last_updated_by,
                                               l_sysdate,
                                               l_last_updated_by,
                                               l_sysdate,
                                               l_last_update_login);
           END IF;--if(l_new_dispute_amount <> l_trx_sum_hist_rec.amount_in_dispute)
          END IF;-- IF get_existing_ps%ROWCOUNT>0 THEN
   CLOSE get_existing_ps;
   /*4021729 set the last update date at time of saving record*/
   l_last_update_date := SYSDATE;
   IF p_update_dff = 'Y'
      THEN UPDATE ar_payment_schedules
              SET staged_dunning_level         = p_staged_dunning_level,
                  dunning_level_override_date  = p_dunning_level_override_date,
                  due_date                     = p_due_date,
                  amount_in_dispute            = p_amount_in_dispute,
                  dispute_date                 = p_dispute_date,
                  attribute_category           = p_attribute_category,
                  attribute1                   = p_attribute1,
                  attribute2                   = p_attribute2,
                  attribute3                   = p_attribute3,
                  attribute4                   = p_attribute4,
                  attribute5                   = p_attribute5,
                  attribute6                   = p_attribute6,
                  attribute7                   = p_attribute7,
                  attribute8                   = p_attribute8,
                  attribute9                   = p_attribute9,
                  attribute10                  = p_attribute10,
                  attribute11                  = p_attribute11,
                  attribute12                  = p_attribute12,
                  attribute13                  = p_attribute13,
                  attribute14                  = p_attribute14,
                  attribute15                  = p_attribute15,
                  global_attribute_category    = p_global_attribute_category,
                  global_attribute1            = p_global_attribute1,
                  global_attribute2            = p_global_attribute2,
                  global_attribute3            = p_global_attribute3,
                  global_attribute4            = p_global_attribute4,
                  global_attribute5            = p_global_attribute5,
                  global_attribute6            = p_global_attribute6,
                  global_attribute7            = p_global_attribute7,
                  global_attribute8            = p_global_attribute8,
                  global_attribute9            = p_global_attribute9,
                  global_attribute10           = p_global_attribute10,
                  global_attribute11           = p_global_attribute11,
                  global_attribute12           = p_global_attribute12,
                  global_attribute13           = p_global_attribute13,
                  global_attribute14           = p_global_attribute14,
                  global_attribute15           = p_global_attribute15,
                  global_attribute16           = p_global_attribute16,
                  global_attribute17           = p_global_attribute17,
                  global_attribute18           = p_global_attribute18,
                  global_attribute19           = p_global_attribute19,
                  global_attribute20           = p_global_attribute20,
                  last_updated_by              = l_last_updated_by,
                  last_update_login            = l_last_update_login,
                  last_update_date             = l_last_update_date
            WHERE payment_schedule_id          = p_ps_id;
      ELSE UPDATE ar_payment_schedules
              SET staged_dunning_level         = p_staged_dunning_level,
                  dunning_level_override_date  = p_dunning_level_override_date,
                  due_date                     = p_due_date,
                  amount_in_dispute            = p_amount_in_dispute,
                  dispute_date                 = p_dispute_date,
                  last_updated_by              = l_last_updated_by,
                  last_update_login            = l_last_update_login,
                  last_update_date             = l_last_update_date
            WHERE payment_schedule_id          = p_ps_id;
   END IF;
    --apandit : bug 2641517 - raising business events.
         IF l_trx_sum_hist_rec.due_date <> p_due_date
            OR nvl(l_trx_sum_hist_rec.amount_in_dispute,0)
                                 <> nvl(p_amount_in_dispute,0)
          THEN

             AR_BUS_EVENT_COVER.Raise_Trx_Modify_Event
                                             (p_ps_id,
                                              l_trx_class,
                                              l_history_id);
         END IF;

EXCEPTION
   WHEN OTHERS
      THEN arp_standard.debug('EXCEPTION: ARP_PROCESS_CUTIL.update_ps ARXCOQIT');
           RAISE;

END;

/*
   Overloaded the procedure so that it can be used by ARXCOECC (Call form) which
   does not want dunning related fields to be updated. This is used when a transaction
   is put on dispute from calls form
*/
procedure update_ps( p_ps_id                   IN ar_payment_schedules.payment_schedule_id%TYPE,
                     p_due_date                IN ar_payment_schedules.due_date%TYPE,
                     p_amount_in_dispute       IN ar_payment_schedules.amount_in_dispute%TYPE,
                     p_dispute_date            IN ar_payment_schedules.dispute_date%TYPE,
                     p_update_dff              IN VARCHAR2,
                     p_attribute_category      IN ar_payment_schedules.attribute_category%TYPE,
                     p_attribute1              IN ar_payment_schedules.attribute1%TYPE,
                     p_attribute2              IN ar_payment_schedules.attribute2%TYPE,
                     p_attribute3              IN ar_payment_schedules.attribute3%TYPE,
                     p_attribute4              IN ar_payment_schedules.attribute4%TYPE,
                     p_attribute5              IN ar_payment_schedules.attribute5%TYPE,
                     p_attribute6              IN ar_payment_schedules.attribute6%TYPE,
                     p_attribute7              IN ar_payment_schedules.attribute7%TYPE,
                     p_attribute8              IN ar_payment_schedules.attribute8%TYPE,
                     p_attribute9              IN ar_payment_schedules.attribute9%TYPE,
                     p_attribute10             IN ar_payment_schedules.attribute10%TYPE,
                     p_attribute11             IN ar_payment_schedules.attribute11%TYPE,
                     p_attribute12             IN ar_payment_schedules.attribute12%TYPE,
                     p_attribute13             IN ar_payment_schedules.attribute13%TYPE,
                     p_attribute14             IN ar_payment_schedules.attribute14%TYPE,
                     p_attribute15             IN ar_payment_schedules.attribute15%TYPE
 )IS
BEGIN

   OPEN get_existing_ps(p_ps_id);

       FETCH get_existing_ps INTO
             l_trx_sum_hist_rec.payment_schedule_id,
             l_trx_sum_hist_rec.currency_code,
             l_trx_sum_hist_rec.due_date,
             l_trx_sum_hist_rec.amount_in_dispute,
             l_trx_sum_hist_rec.amount_due_original,
             l_trx_sum_hist_rec.amount_due_remaining,
             l_trx_sum_hist_rec.amount_adjusted,
             l_trx_sum_hist_rec.customer_trx_id,
             l_trx_sum_hist_rec.customer_id,
             l_trx_sum_hist_rec.site_use_id,
             l_trx_class,
             l_trx_sum_hist_rec.trx_date,
             l_old_dispute_date;

         IF l_trx_sum_hist_rec.due_date <> p_due_date
            OR nvl(l_trx_sum_hist_rec.amount_in_dispute,0)
                                 <> nvl(p_amount_in_dispute,0)
          THEN

             AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                                      l_history_id,
                                                      l_trx_class,
                                                      'MODIFY_TRX');
         END IF;
         /*Bug 5129946: Calling arp_dispute_history.DisputeHistory*/
         IF get_existing_ps%ROWCOUNT>0 THEN
         l_new_dispute_amount := p_amount_in_dispute;
         l_new_dispute_date := p_dispute_date;
         if(l_new_dispute_amount <> l_trx_sum_hist_rec.amount_in_dispute)
            OR (l_new_dispute_amount IS NULL and l_trx_sum_hist_rec.amount_in_dispute IS NOT NULL)
            OR (l_new_dispute_amount IS  NOT NULL and l_trx_sum_hist_rec.amount_in_dispute IS  NULL)
            THEN
            arp_dispute_history.DisputeHistory(l_new_dispute_date,
                                               l_old_dispute_date,
                                               l_trx_sum_hist_rec.payment_schedule_id,
                                               l_trx_sum_hist_rec.payment_schedule_id,
                                               l_trx_sum_hist_rec.amount_due_remaining,
                                               l_new_dispute_amount,
                                               l_trx_sum_hist_rec.amount_in_dispute,
                                               l_last_updated_by,
                                               l_sysdate,
                                               l_last_updated_by,
                                               l_sysdate,
                                               l_last_update_login);
           END IF;--if(l_new_dispute_amount <> l_trx_sum_hist_rec.amount_in_dispute)
         END IF;--IF get_existing_ps%ROWCOUNT>0 THEN
   CLOSE get_existing_ps;
   /*4021729 set the last update date at time of saving record*/
   l_last_update_date := SYSDATE;
   IF p_update_dff = 'Y'
      THEN UPDATE ar_payment_schedules
              SET due_date                     = p_due_date,
                  amount_in_dispute            = p_amount_in_dispute,
                  dispute_date                 = p_dispute_date,
                  attribute_category           = p_attribute_category,
                  attribute1                   = p_attribute1,
                  attribute2                   = p_attribute2,
                  attribute3                   = p_attribute3,
                  attribute4                   = p_attribute4,
                  attribute5                   = p_attribute5,
                  attribute6                   = p_attribute6,
                  attribute7                   = p_attribute7,
                  attribute8                   = p_attribute8,
                  attribute9                   = p_attribute9,
                  attribute10                  = p_attribute10,
                  attribute11                  = p_attribute11,
                  attribute12                  = p_attribute12,
                  attribute13                  = p_attribute13,
                  attribute14                  = p_attribute14,
                  attribute15                  = p_attribute15,
                  last_updated_by              = l_last_updated_by,
                  last_update_login            = l_last_update_login,
                  last_update_date             = l_last_update_date
            WHERE payment_schedule_id          = p_ps_id;
      ELSE UPDATE ar_payment_schedules
              SET due_date                     = p_due_date,
                  amount_in_dispute            = p_amount_in_dispute,
                  dispute_date                 = p_dispute_date,
                  last_updated_by              = l_last_updated_by,
                  last_update_login            = l_last_update_login,
                  last_update_date             = l_last_update_date
            WHERE payment_schedule_id          = p_ps_id;
   END IF;
    --apandit : bug 2641517 - raising business events.
         IF l_trx_sum_hist_rec.due_date <> p_due_date
            OR nvl(l_trx_sum_hist_rec.amount_in_dispute,0)
                                 <> nvl(p_amount_in_dispute,0)
          THEN

             AR_BUS_EVENT_COVER.Raise_Trx_Modify_Event
                                             (p_ps_id,
                                              l_trx_class,
                                              l_history_id);
         END IF;

EXCEPTION
   WHEN OTHERS
      THEN arp_standard.debug('EXCEPTION: ARP_PROCESS_CUTIL.update_ps ARXCOECC Dispute Action');
           RAISE;

END;
procedure update_ps( p_ps_id                       IN ar_payment_schedules.payment_schedule_id%TYPE,
                     p_exclude_from_dunning        IN ar_payment_schedules.exclude_from_dunning_flag%TYPE,
                     p_update_dff                  VARCHAR2,
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
)
IS
BEGIN
   /*4021729 set the last update date at time of saving record*/
   l_last_update_date := SYSDATE;
   IF p_update_dff = 'Y'
      THEN UPDATE ar_payment_schedules
              SET exclude_from_dunning_flag    = p_exclude_from_dunning,
                  attribute_category           = p_attribute_category,
                  attribute1                   = p_attribute1,
                  attribute2                   = p_attribute2,
                  attribute3                   = p_attribute3,
                  attribute4                   = p_attribute4,
                  attribute5                   = p_attribute5,
                  attribute6                   = p_attribute6,
                  attribute7                   = p_attribute7,
                  attribute8                   = p_attribute8,
                  attribute9                   = p_attribute9,
                  attribute10                  = p_attribute10,
                  attribute11                  = p_attribute11,
                  attribute12                  = p_attribute12,
                  attribute13                  = p_attribute13,
                  attribute14                  = p_attribute14,
                  attribute15                  = p_attribute15,
                  last_updated_by              = l_last_updated_by,
                  last_update_login            = l_last_update_login,
                  last_update_date             = l_last_update_date
            WHERE payment_schedule_id          = p_ps_id;
      ELSE UPDATE ar_payment_schedules
              SET exclude_from_dunning_flag    = p_exclude_from_dunning,
                  last_updated_by              = l_last_updated_by,
                  last_update_login            = l_last_update_login,
                  last_update_date             = l_last_update_date
            WHERE payment_schedule_id          = p_ps_id;
   END IF;

EXCEPTION
   WHEN OTHERS
      THEN arp_standard.debug('EXCEPTION: ARP_PROCESS_CUTIL.update_ps Dunning Action');
           RAISE;

END;
procedure update_ps_fdate( p_ps_id                 IN ar_payment_schedules.payment_schedule_id%TYPE,
                           p_follow_up_date        IN ar_payment_schedules.follow_up_date_last%TYPE)
IS
BEGIN
    IF p_ps_id IS NOT NULL THEN
       UPDATE ar_payment_schedules
       SET  follow_up_date_last = p_follow_up_date
       WHERE payment_schedule_id = p_ps_id;
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
             arp_standard.debug('EXCEPTION : ARP_PROCESS_CUTIL.update_ps_fdate Follow up Date ');
        RAISE;
END;

END;

/
