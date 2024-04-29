--------------------------------------------------------
--  DDL for Package Body ARP_TRX_SUM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_SUM_UTIL" AS
/* $Header: ARTUSUMB.pls 115.4 2003/10/10 14:29:45 mraymond ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_batch_summary                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the actual count or actual amount of the transactions for      |
 |    a given batch.                                                         |
 |                                                                           |
 |    If p_mode is "SUM" then the sum of the amounts of the transactions     |
 |    in the batch is returned. Otherwise the count of the transactions is   |
 |    returned                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id                                             |
 |                    p_mode      (SUM/COUNT)                                |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NUMBER    count/amount of transactions in the batch          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-NOV-95  Subash C            Created                                |
 |                                                                           |
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION get_batch_summary(
  p_batch_id IN number,
  p_mode     IN varchar2 ) RETURN number
IS
  l_sum_value  number := null;
BEGIN

   IF (nvl(p_mode, 'SUM') = 'SUM')
   THEN
       SELECT nvl(sum(lgd.amount), 0)
       INTO   l_sum_value
       FROM   ra_customer_trx ct,
              ra_cust_trx_line_gl_dist lgd
       WHERE  ct.customer_trx_id  = lgd.customer_trx_id
       AND    ct.batch_id         = p_batch_id
       AND    lgd.account_class   = 'REC'
       AND    lgd.latest_rec_flag = 'Y';
   ELSE
       SELECT count(*)
       INTO   l_sum_value
       FROM   ra_customer_trx ct
       WHERE  ct.batch_id = p_batch_id;
   END IF;

   RETURN(l_sum_value);

END get_batch_summary;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_batch_summary_all                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the actual count and actual amount of the transactions for     |
 |    a given batch.                                                         |
 |                                                                           |
 |    Will be called in POST-FORMS-COMMIT trigger from transactions WB to    |
 |    update values  without having to requery the trx batches form.         |
 |                                                                           |
 |    implemented as a fix for Enhancement #561984.                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id                                             |
 |              OUT:                                                         |
 |                    l_actual_count                                         |
 |                    l_actual_amount                                        |
 | NOTES                                                                     |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-OCT-95  Debbie Jancis         Created                              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_batch_summary_all ( p_batch_id IN number,
                                  l_actual_count OUT NOCOPY number,
                                  l_actual_amount OUT NOCOPY number )

IS
BEGIN

  l_actual_amount := null;
  l_actual_count  := null;

       /*  get actual_amount */
       SELECT nvl(sum(lgd.amount), 0)
       INTO   l_actual_amount
       FROM   ra_customer_trx ct,
              ra_cust_trx_line_gl_dist lgd
       WHERE  ct.customer_trx_id  = lgd.customer_trx_id
       AND    ct.batch_id         = p_batch_id
       AND    lgd.account_class   = 'REC'
       AND    lgd.latest_rec_flag = 'Y';

       /* get actual count  */
       SELECT count(*)
       INTO   l_actual_count
       FROM   ra_customer_trx ct
       WHERE  ct.batch_id = p_batch_id;

END get_batch_summary_all;


END ARP_TRX_SUM_UTIL;

/
